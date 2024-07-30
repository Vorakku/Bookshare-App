<?php
namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Models\User;
use App\Models\Booklist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BooklistController extends Controller
{
    public function updateStatus(Request $request, $id)
    {
        $user = auth()->user();
        if (!($user instanceof User)) {
            return response()->json([
                'message' => 'Authenticated user not found or is not an instance of User model'
            ], 500);
        }
        $booklist = Booklist::findOrFail($id);
        $this->validate($request, [
            'public' => 'required|boolean',
        ]);
        $booklist->public = $request->public;
        $booklist->save();

        return response()->json([
            'message' => 'Status Has been Updated'
        ]);
    }

    // For viewing the booklist
    public function view($id, $token)
    {
        $booklist = Booklist::findOrFail($id);

        if (auth()->check()) {
            return view('booklist.view', compact('booklist'));
        } else {
            return view('booklist.guest', compact('booklist'));
        }
    }

    public function generateSharableLink($booklistId)
    {
        $booklist = Booklist::findOrFail($booklistId);
        $uniqueUrl = route('booklist.view', ['id' => $booklist->id, 'token' => Str::random(32)]);

        return response()->json(['url' => $uniqueUrl]);
    }

    public function viewBookList()
    {
        // Retrieve all book lists with associated books and user details
        $booklists = Booklist::with(['books', 'user'])->get();

        // Return the data as a JSON response
        return response()->json($booklists);
    }

    public function viewBookListByUserId() 
{
    $user = auth()->user();
    if (!($user instanceof User)) {
        return response()->json([
            'message' => 'Authenticated user not found or is not an instance of User model'
        ], 500);
    }
    $booklists = Booklist::with(['books', 'user'])->where('user_id', $user->id)->get();
    return response()->json($booklists);
}

    public function viewPublicBooklist($userId)
    {
        $user = auth()->user();
        if (!($user instanceof User)) {
            return response()->json([
                'message' => 'Authenticated user not found or is not an instance of User model'
            ], 500);
        }
        $booklists = Booklist::with(['books', 'user'])
        ->where('user_id', $userId)->where('public', 1)->get();
    return response()->json($booklists);
    }

    public function viewPrivateBooklist($userId) 
    {
        $user = auth()->user();
        // IMPORTANT: Check if the authenticated user is an instance of User model
        if (!($user instanceof User)) {
            return response()->json([
                'message' => 'Authenticated user not found or is not an instance of User model'
            ], 500);
        }

        $booklists = Booklist::with(['books', 'user'])
        ->where('user_id', $userId)
        ->where('public', 0)
        ->get();
        return response()->json($booklists);
    }
    

    public function createBookList(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string',
            // 'public' => 'boolean', 
            // Add validation for public attribute
        ]);
        // If validation fails, return error response
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $booklist = new Booklist();
        $booklist->user_id = auth()->id();
        $booklist->name = $request->name;
        $booklist->public = $request->public ?? false; // Set default value for public attribute
        $booklist->save();

        return response()->json($booklist->load('books'), 201);
    }

    public function addBookToBooklist(Request $request)
    {
        $user = auth()->user();

        $validator = Validator::make($request->all(), [
            'booklist_id' => 'required|exists:booklists,id',
            'book_id' => 'required|exists:books,id',
            'book_ids.*' => 'exists:libraries,book_id,user_id,' . $user->id,
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $booklist = Booklist::find($request->booklist_id);
        if (!$booklist) {
            return response()->json(['error' => 'Booklist not found'], 404);
        }
        if ($booklist->user_id != $user->id) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }
        $bookInLibrary = DB::table('libraries')
            ->where('user_id', $user->id)
            ->where('book_id', $request->book_id)
            ->exists();
        if (!$bookInLibrary) {
            return response()->json(['error' => 'Book not found in user\'s library'], 422);
        }
        $bookExistAlready = DB::table('booklist_book')
            ->where('booklist_id', $request->booklist_id)
            ->where('book_id', $request->book_id)
            ->exists();

        if ($bookExistAlready) {
            return response()->json(['error' => 'Book already exists in the booklist'], 422);
        }
        $booklist->books()->attach($request->book_id);
        return response()->json($booklist->load('books'), 201);
    }

    public function removeBookFromBooklist(Request $request)
    {
        $user = auth()->user();

        if (!$user) {
            return response()->json(['error' => 'User not authenticated'], 401);
        }

        $validator = Validator::make($request->all(), [
            'booklist_id' => 'required|exists:booklists,id',
            'book_id' => 'required|exists:books,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $booklist = Booklist::where('id', $request->booklist_id)
            ->where('user_id', $user->id)
            ->first();

        if (!$booklist) {
            return response()->json(['error' => 'Booklist not found or does not belong to user'], 404);
        }

        $bookInBooklist = $booklist->books()->where('book_id', $request->book_id)->exists();

        if (!$bookInBooklist) {
            return response()->json(['error' => 'Book not found in booklist'], 404);
        }

        $booklist->books()->detach($request->book_id);

        return response()->json(null, 204);
    }

    public function deleteBooklist(Request $request)
    {
        $user = auth()->user();

        if (!$user) {
            return response()->json(['error' => 'User not authenticated'], 401);
        }

        $validator = Validator::make($request->all(), [
            'booklist_id' => 'required|exists:booklists,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $booklist = Booklist::where('id', $request->booklist_id)
            ->where('user_id', $user->id)
            ->first();

        if (!$booklist) {
            return response()->json(['error' => 'Booklist not found or does not belong to user'], 404);
        }

        $booklist->delete();

        return response()->json(null, 204);
    }
}
