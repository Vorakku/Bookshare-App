<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Book;
use App\Models\Like;

class BookController extends Controller
{
    public function getRecentBooks()
    {
        $recentBooks = Book::with('user')->orderBy('created_at', 'desc')->take(45)->get();
        return response()->json($recentBooks, 200);
    }
    public function store(Request $request)
    {
        try {    
            $validatedData = $request->validate([
            'title' => 'required|string|unique:books|max:255',
            'description' => 'required|string',
            'isbn' => 'required|string|unique:books|max:255',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'genre' => 'required|string|in:adventure,horror,romance,comedy,fiction,nonfiction,fantasy,sciencefiction,mystery,romance,historical,horror,biography,selfhelp,poetry,youngadult,comics,travel,cookbooks,drama,adventure,humor,memoir',
            'publisher' => 'required|string|max:255',
            'publishdate' => 'required|date_format:m/d/Y',
            'number_of_pages' => 'required|integer',
            'language' => 'required|string|in:english,khmer,japanese,korean',
            'status' => 'required|boolean',
        ]);

        $user = auth()->user();

        $imagePath = $request->file('image')->store('books', 'public');
        $imageUrl = config('app.url') . '/storage/' . $imagePath;
        // $imageUrl = env('APP_URL') . '/storage/' . $imagePath;
        $publishdate = \Carbon\Carbon::createFromFormat('m/d/Y', $validatedData['publishdate'])->format('Y-m-d');

        $book = new Book([
            'title' => $validatedData['title'],
            'description' => $validatedData['description'],
            'isbn' => $validatedData['isbn'],
            'image_url' => $imageUrl,
            'genre' => $validatedData['genre'],
            'publisher' => $validatedData['publisher'],
            'publishdate' => $publishdate,
            'number_of_pages' => $validatedData['number_of_pages'],
            'language' => $validatedData['language'],
            'status' => $validatedData['status'],
            'user_id' => $user->id,
        ]);

        $book->save();

        return response()->json(['success' => true, 'book' => $book], 201);}
        
        catch (\Illuminate\Validation\ValidationException $e) {
            // Debugging: Log validation errors
            error_log('Validation errors: ' . json_encode($e->errors()));
            
            return response()->json(['success' => false, 'errors' => $e->errors()], 422);
        } catch (\Exception $e) {
            // Debugging: Log any other errors
            error_log('Error: ' . $e->getMessage());
            
            return response()->json(['success' => false, 'message' => 'An error occurred. Please try again.'], 500);
        } 
    }

    public function getBooks()
    {
        $books = Book::with('user')->get();
        return response()->json($books, 200);
    }

    public function getBooksTitle(){
        $bookTitles = Book::pluck('title');
        return response()->json($bookTitles, 200);
    }

    public function getBooksByUser()
    {
        $user = auth()->id();
        $books = Book::where('user_id', $user)->get();
        return response()->json($books, 200);
    }

    public function like($id)
    {
        $book = Book::findOrFail($id);
        $user = auth()->user();

        if (!$book->isLikedByUser($user->id)) {
            Like::create([
                'user_id' => $user->id,
                'book_id' => $book->id
            ]);
        }

        return response()->json([
            'success' => true,
            'likes' => $book->likes()->count()
        ]);
    }

    public function unlike($id)
    {
        $book = Book::findOrFail($id);
        $user = auth()->user();

        $like = Like::where('user_id', $user->id)->where('book_id', $book->id)->first();

        if ($like) {
            $like->delete();
        }

        return response()->json([
            'success' => true,
            'likes' => $book->likes()->count()
        ]);
    }

    public function hasLiked($id)
    {
        $book = Book::findOrFail($id);
        $user = auth()->user();

        return response()->json([
            'success' => true,
            'hasLiked' => $user->likes->contains($book->id),
            'totalLikes' => $book->likes()->count()
        ]);
    }

    public function topLikedBooks()
    {
        $topBook = Book::with('user')->withCount('likes')
            ->orderBy('likes_count', 'desc')
            ->take(10)
            ->get();

        return response()->json([
            'success' => true,
            'topBooks' => $topBook
        ]);
    }
}
