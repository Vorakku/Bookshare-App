<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('booklists', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->string('name');
            $table->boolean('public')->default(false); // Add the public field here
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });

        Schema::create('booklist_book', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('booklist_id');
            $table->unsignedBigInteger('book_id');
            $table->timestamps();

            $table->foreign('booklist_id')->references('id')->on('booklists')->onDelete('cascade');
            $table->foreign('book_id')->references('id')->on('books')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('booklist_book');
        Schema::dropIfExists('booklists');
    }
};


