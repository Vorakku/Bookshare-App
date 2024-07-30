<!-- resources/views/booklist/view.blade.php -->

@extends('layouts.app')

@section('content')
    <div class="container">
        <h1>{{ $booklist->name }}</h1>
        <ul>
            @foreach ($booklist->books as $book)
                <li>{{ $book->title }}</li>
            @endforeach
        </ul>
    </div>
@endsection
