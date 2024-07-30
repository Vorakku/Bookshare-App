<!-- resources/views/booklist/guest.blade.php -->

@extends('layouts.app')

@section('content')
    <div class="container">
        <h1>Name of Booklist: {{ $booklist->name }}</h1>
        <p>Please <a href="{{ route('login') }}">login</a> to view the full booklist.</p>
        <div class="row">
            @foreach ($booklist->books as $book)
                <div class="col-md-4 mb-4">
                    <div class="card">
                        <img src="{{ $book->image_url }}" class="card-img-top" alt="{{ $book->title }}" style="height: 200px; object-fit: cover;">
                        <div class="card-body">
                            <h5 class="card-title"> Name of Book: {{ $book->title }}</h5>
                            <p class="card-text"> Publisher: {{ $book->publisher }}</p>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
@endsection
