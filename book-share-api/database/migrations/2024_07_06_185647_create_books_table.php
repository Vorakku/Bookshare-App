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
        Schema::create('books', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->longText('description');
            $table->date('publishdate');
            $table->string('isbn');
            $table->string('image_url');
            $table->enum('genre', ['adventure', 'horror', 'romance', 'comedy']);
            $table->string('publisher');
            $table->integer('number_of_pages');
            $table->enum('language', ['english', 'khmer', 'japanese', 'korean']);
            $table->boolean('status')->default(true);
            $table->unsignedBigInteger('user_id');
            $table->foreign('user_id')->references('id')->on('users');
            $table->timestamps();
        });
    } 

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('books');
    }
};
