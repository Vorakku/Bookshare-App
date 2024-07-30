<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Comment;
class CommentController extends Controller
{
    public function store(Request $request)
    {
        $validate = $request->validate([
            'book_id' => 'required|exists:books,id',
            'comment' => 'required|string'
        ]);
    
        $comment = new Comment();
        $comment->user_id = auth()->id();
        $comment->book_id = $request->book_id;
        $comment->comment = $request->comment;
        $comment->save();
    
        return response()->json($comment, 201);
    }

    public function index($bookId)
    {
        $comments = Comment::where('book_id', $bookId)->with('user')->get();
        return response()->json($comments, 200);
    }
}
