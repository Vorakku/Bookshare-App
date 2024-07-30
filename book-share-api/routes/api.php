<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\BookController;
use App\Http\Controllers\BooklistController;
use App\Http\Controllers\LibraryController;
use App\Http\Controllers\CommentController;
/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
//     return $request->user();
// });

Route::middleware('auth:sanctum')->group(function () {
    // Route::get('/user', function (Request $request) {
    //     return $request->user();
    // });

    //Other Users Api
    Route::middleware('throttle:500,1')->group(function () {
        Route::get('user/{id}', [AuthController::class, 'getUserProfile']);
    //Other Users Api

    //User Profile Api
    Route::get('/users/user', [AuthController::class, 'getUser']);
    Route::post('add_profile/user', [AuthController::class, 'addProfile']);  
    Route::post('add_description/user', [AuthController::class, 'addDescription']);
    Route::put('user/username', [AuthController::class, 'updateUsername']);
    //User Profile Api

    //Comments Api
    Route::post('comments', [CommentController::class, 'store']);
    //Comments Api

    //Booklist Api
    Route::get('view_booklists', [BooklistController::class, 'view']);
    Route::get('view_booklists/{userId}/public', [BooklistController::class, 'viewPublicBooklist']);
    Route::get('view_booklists/{userId}/private', [BooklistController::class, 'viewPrivateBooklist']);
    Route::get('view_booklists/user', [BookListController::class, 'viewBookListByUserId']);
    Route::post('create_booklist', [BookListController::class, 'createBookList']);
    Route::post('add_book_to_booklist', [BookListController::class, 'addBookToBooklist']);
    Route::post('booklist/generate-link/{booklistId}', [BooklistController::class, 'generateSharableLink']);
    Route::delete('/booklist/delete', [BooklistController::class, 'deleteBooklist']);
    Route::post('booklist/removeBook', [BooklistController::class, 'removeBookFromBooklist']);
    Route::put('/booklists/{id}/status', [BooklistController::class, 'updateStatus']);
    //Booklist Api

    //Add Book Api
    Route::post('addbooks', [BookController::class, 'store']);
    Route::get('getbooks/user', [BookController::class, 'getBooksByUser']);
    Route::get('books/recent', [BookController::class, 'getRecentBooks']);
    Route::get('get_books_title', [BookController::class, 'getBooksTitle']);
    //Add Book Api

    //Library Api
    Route::get('library', [LibraryController::class, 'viewLibrary']);
    Route::get('library/user', [LibraryController::class, 'viewLibraryByUser']);
    Route::post('add_book_to_library', [LibraryController::class, 'addBookToLibrary']);
    Route::delete('library/{bookid}', [LibraryController::class, 'removeBookFromLibrary']);
    Route::post('/library/{bookId}/bookmark', [LibraryController::class, 'saveBookmark']);
    Route::get('/library/{bookId}/bookmark', [LibraryController::class, 'getBookmark']);
    //Library Api

    //Like Api
    Route::post('books/{id}/like', [BookController::class, 'like']);
    Route::post('books/{id}/unlike', [BookController::class, 'unlike']);
    Route::get('books/{id}/liked', [BookController::class, 'hasLiked']);

    //Like Api  
    });
});


//Public Routes
Route::get('users', [AuthController::class, 'getAllUser']);
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);
Route::get('getbooks', [BookController::class, 'getBooks']);
Route::get('view_booklists', [BookListController::class, 'viewBookList']);
Route::get('books/{book}/comments', [CommentController::class, 'index']);
Route::get('books/top_like', [BookController::class, 'topLikedBooks']);







// Route::middleware('auth:sanctum')->group(function () {
    
// });// Route::middleware('auth:api')->group(function () {
//     Route::post('/books', [BookController::class, 'store']);
// });
// Route::middleware('auth:api')->group(function () {

// Route::get('/booklists', [BooklistController::class, 'index']);
// Route::post('/booklists', [BooklistController::class, 'store']);
// Route::post('/booklists/{booklist}/add-book', [BooklistController::class, 'addBook']);