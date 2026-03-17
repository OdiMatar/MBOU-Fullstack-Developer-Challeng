<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        // Maak admin account
        User::create([
            'name' => 'Odai Admin',
            'email' => 'admin@odai.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
        ]);

        // Maak test gebruiker
        User::create([
            'name' => 'Test Gebruiker',
            'email' => 'user@test.com',
            'password' => Hash::make('user123'),
            'role' => 'user',
        ]);
    }
}
