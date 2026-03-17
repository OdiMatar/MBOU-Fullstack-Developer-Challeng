<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    private function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'profile_image' => $user->profile_image,
            'bio' => $user->bio,
            'phone' => $user->phone,
            'location' => $user->location,
        ];
    }

    private function deleteProfileImageIfLocal(?string $imagePath): void
    {
        if (!$imagePath) {
            return;
        }

        if (str_starts_with($imagePath, 'http://') || str_starts_with($imagePath, 'https://')) {
            return;
        }

        $urlPath = parse_url($imagePath, PHP_URL_PATH) ?: $imagePath;
        $fullPath = public_path(ltrim($urlPath, '/'));

        if (is_file($fullPath)) {
            @unlink($fullPath);
        }
    }

    // Haal alle users op (alleen voor admin)
    public function index()
    {
        $users = User::orderBy('created_at', 'desc')->get();
        
        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }

    // Update user profiel
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Gebruiker niet gevonden'
            ], 404);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $id,
            'password' => 'sometimes|string|min:6',
            'profile_image' => 'sometimes|nullable|string|max:500',
            'bio' => 'sometimes|nullable|string|max:1000',
            'phone' => 'sometimes|nullable|string|max:50',
            'location' => 'sometimes|nullable|string|max:255',
            'profile_image_file' => 'sometimes|nullable|image|mimes:jpg,jpeg,png,webp|max:4096',
            'remove_profile_image' => 'sometimes|boolean',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        foreach (['bio', 'phone', 'location'] as $field) {
            if (array_key_exists($field, $validated) && $validated[$field] === '') {
                $validated[$field] = null;
            }
        }

        if ($request->boolean('remove_profile_image')) {
            $this->deleteProfileImageIfLocal($user->profile_image);
            $validated['profile_image'] = null;
        }

        if ($request->hasFile('profile_image_file')) {
            $this->deleteProfileImageIfLocal($user->profile_image);

            $directory = public_path('uploads/profile-images');
            if (!is_dir($directory)) {
                mkdir($directory, 0755, true);
            }

            $file = $request->file('profile_image_file');
            $filename = 'user_' . $user->id . '_' . time() . '.' . $file->getClientOriginalExtension();
            $file->move($directory, $filename);

            $validated['profile_image'] = '/uploads/profile-images/' . $filename;
        }

        unset($validated['profile_image_file'], $validated['remove_profile_image']);

        $user->update($validated);
        $user->refresh();

        return response()->json([
            'success' => true,
            'message' => 'Profiel bijgewerkt',
            'user' => $this->userPayload($user)
        ]);
    }

    // Verwijder user (alleen admin)
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Gebruiker niet gevonden'
            ], 404);
        }

        // Voorkom dat admin zichzelf verwijdert
        if ($user->role === 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Admin accounts kunnen niet verwijderd worden'
            ], 403);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Gebruiker verwijderd'
        ]);
    }
}
