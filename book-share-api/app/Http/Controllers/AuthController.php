<?php

namespace App\Http\Controllers;

use App\Models\Library;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{


    public function updateUsername(Request $request)
    {
        $request->validate([
            'username' => 'required|string|max:255|unique:users',
        ]);

        $user = auth()->user();
        
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $user->username = $request->username;
        $user->save();

        return response()->json(['message' => 'Username updated successfully']);
    }
        public function getUserProfile($userId)
        {
            $finduser = User::find($userId);

            if (!$finduser) 
            {
                return response()->json
                (
                    [
                        'message' => 'User Not Found'
                    ],
                    404
                );
            }
            return response()->json($finduser);
        }

    public function getUser()

    {
        $user = auth()->user();
        
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json($user);
    }

    public function addProfile(Request $request)
    {

        $request->validate([
            'profile_image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        // $user = User::find($userId);


        $user = auth()->user();
        //IMPORTANT: Check if the authenticated user is an instance of User model
        if (!($user instanceof User)) {
            return response()->json([
                'message' => 'Authenticated user not found or is not an instance of User model'
            ], 500);
        }
        //IMPORTANT: Check if the authenticated user is an instance of User model
        
        if ($request->hasFile('profile_image')) {
            $image = $request->file('profile_image');
            $name = time() . '.' . $image->getClientOriginalExtension();
            $imagePath = $image->storeAs('profile', $name, 'public');
            $imageUrl = env('APP_URL') . '/storage/' . $imagePath;

            // $path = $image->store('profile', 'public');

            if($user->profile_image){
                Storage::delete('/public/' . $user->profile_image);
            }

            $user->profile_image = $imageUrl;
        }

        $user->save();

        return response()->json([
            'message' => 'Profile image added successfully',
            'user' => $user
        ], 200);
    }

    public function addDescription(Request $request)
    {
        $request->validate([
            'description' => 'required|string',
        ]);

        // $user = User::find($userId);
        $user = auth()->user();

        //IMPORTANT: Check if the authenticated user is an instance of User model
        if (!($user instanceof User)) {
            return response()->json([
                'message' => 'Authenticated user not found or is not an instance of User model'
            ], 500);
        }
        //IMPORTANT: Check if the authenticated user is an instance of User model

        $user->description = $request->description;
        $user->save();

        return response()->json([
            'message' => 'Description added successfully',
            'user' => $user
        ], 200);
    }

    public function getAllUser()
    {
        $uers = User::all();
        return response()->json($uers);
    }

    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $user = User::create([
            'username' => $request->username,
            'password' => Hash::make($request->password),
        ]);

        // Create a library for the user
        $library = Library::create([
            'user_id' => $user->id,
        ]);
        // Create a library for the user

        return response()->json([
            'message' => 'User successfully registered',
            'user' => $user,
            'user-library' => $library,
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);
    
        $credentials = $request->only('username', 'password');
    
        if (!auth()->attempt($credentials)) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }
    
        $user = auth()->user();

        $token = $request->user()->createToken('auth_token')->plainTextToken;
    
        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
            ],
        ], 200);
    }    
}
