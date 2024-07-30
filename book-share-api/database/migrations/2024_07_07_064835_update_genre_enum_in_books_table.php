<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        DB::statement("ALTER TABLE books MODIFY genre ENUM(
            'fiction', 
            'nonfiction', 
            'fantasy', 
            'sciencefiction', 
            'mystery', 
            'romance', 
            'historical', 
            'horror', 
            'biography', 
            'selfhelp', 
            'poetry', 
            'youngadult', 
            'comics', 
            'travel', 
            'cookbooks', 
            'drama', 
            'adventure', 
            'humor', 
            'memoir'
        ) NOT NULL");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement("ALTER TABLE books MODIFY genre ENUM('adventure', 'horror', 'romance', 'comedy') NOT NULL");
    }
};
