<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booklist extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'user_id', 'public', // Ensure public is here
    ];

    public function books()
    {
        return $this->belongsToMany(Book::class, 'booklist_book');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

