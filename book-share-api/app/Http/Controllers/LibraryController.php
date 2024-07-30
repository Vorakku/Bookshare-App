<?php

namespace App\Http\Controllers;

use App\Models\Library;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LibraryController extends Controller
{

    public function saveBookmark(Request $request, $bookId) {
        $userId = auth()->id();
        $currentPage = $request->input('current_page');
    
        $book = Book::find($bookId);
        if (!$book) {
            return response()->json(['success' => false, 'message' => 'Book not found'], 404);
        }   

        $totalPages = $book->number_of_pages;

        if($currentPage > $totalPages) {
            return response()->json(['success' => false, 'message' => 'Current page cannot be greater than total pages'], 400);
        } else if ($currentPage < 0) {
            return response()->json(['success' => false, 'message' => 'Current page cannot be less than 0'], 400);
        }

        $library = Library::where('user_id', $userId)->where('book_id', $bookId)->first();
        if ($library) {
            $library->current_page = $currentPage;
            $library->save();
            return response()->json(['success' => true, 'library' => $library], 200);
        } else {
            return response()->json(['success' => false, 'message' => 'Book not found in library'], 404);
        }
    }

    public function getBookmark($bookId) {
        $userId = auth()->id();
    
        $library = Library::where('user_id', $userId)->where('book_id', $bookId)->first(['current_page']);
    
        if ($library) {
            return response()->json(['success' => true, 'current_page' => $library->current_page], 200);
        } else {
            return response()->json(['success' => false, 'message' => 'Bookmark not found'], 404);
        }
    }

    public function viewLibrary()
    {
        // Retrieve all libraries with associated books and users
        $libraries = Library::with(['book', 'user'])->get();

        // Return the data as a JSON response
        return response()->json($libraries);
    }

    public function viewLibraryByUser()
    {
        $user = auth()->id();
        $libraries = Library::with(['book', 'user'])
            ->where('user_id', $user)
            ->get();
    
        if ($libraries->isEmpty()) {
            return response()->json(['error' => 'No libraries found for this user.'], 404); // 404 Not Found
        }
    
        // Return the data as a JSON response
        return response()->json($libraries);
    }


    public function addBookToLibrary(Request $request)
    {
        // Validate the request data
        $validator = Validator::make($request->all(), [
            // 'user_id' => 'required|exists:users,id',
            'book_id' => 'required|exists:books,id',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = auth()->id();

        // Check if the book already exists in the library for the user
        $existingEntry = Library::where('user_id', $user)
            ->where('book_id', $request->book_id)
            ->first();

        if ($existingEntry) {
            return response()->json(['error' => 'This book is already in the library for this user.'], 409); // 409 Conflict
        }

        $library = Library::create([
            'user_id' => $user,
            'book_id' => $request->book_id,
        ]);

        return response()->json([
            'message' => 'Book added sucessfully',
            'libarry' => $library,
        ], 201);
    }

    public function removeBookFromLibrary($bookId) {
        $user = auth()->user();

        if (!$user) {
            return response()->json(['error' => 'User not authenticated'], 401);
        }

        $library = Library::where('user_id', $user->id)->where('book_id', $bookId)->first();

        if ($library) {
            $library->delete();
            return response()->json(null, 204);
        } else {
            return response()->json(['error' => 'Book not found in library'], 404);
        }
    }
}
