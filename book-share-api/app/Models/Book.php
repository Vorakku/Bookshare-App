<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Book extends Model
{
    use HasFactory;
    protected $fillable = [
        'title',
        'description',
        'isbn',
        'image_url',
        'genre',
        'publisher',
        'publishdate',
        'number_of_pages',
        'language',
        'status',
        'user_id',
        'likes',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function libraries()
    {
        return $this->hasMany(Library::class);
    }

    //Added on 29/06/24
    public function booklists()
    {
        return $this->belongsToMany(Booklist::class, 'booklist_book');
    }

    public function comments()
    {
        return $this->hasMany(Comment::class);  
    }

    public function likes() {
        return $this->belongsToMany(User::class, 'likes');
    }

    public function isLikedByUser($userId){
        return $this->likes()->where('user_id', $userId)->exists();
    }

}


