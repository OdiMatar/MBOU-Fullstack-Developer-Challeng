<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;

class ItemController extends Controller
{
    // GET /api/items - Alle items ophalen
    public function index()
    {
        $items = Item::orderBy('created_at', 'desc')->get();
        
        return response()->json([
            'success' => true,
            'data' => $items
        ]);
    }

    // POST /api/items - Nieuw item aanmaken
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'brand' => 'nullable|string|max:255',
            'price' => 'nullable|numeric|min:0',
            'stock' => 'nullable|integer|min:0',
            'image_url' => 'nullable|string|max:500',
        ]);

        $item = Item::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Item succesvol aangemaakt',
            'data' => $item
        ], 201);
    }

    // GET /api/items/{id} - Enkel item ophalen
    public function show($id)
    {
        $item = Item::find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Item niet gevonden'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $item
        ]);
    }

    // PUT /api/items/{id} - Item updaten
    public function update(Request $request, $id)
    {
        $item = Item::find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Item niet gevonden'
            ], 404);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'brand' => 'nullable|string|max:255',
            'price' => 'nullable|numeric|min:0',
            'stock' => 'nullable|integer|min:0',
            'image_url' => 'nullable|string|max:500',
        ]);

        $item->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Item succesvol geüpdatet',
            'data' => $item
        ]);
    }

    // DELETE /api/items/{id} - Item verwijderen
    public function destroy($id)
    {
        $item = Item::find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Item niet gevonden'
            ], 404);
        }

        $item->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item succesvol verwijderd'
        ]);
    }
}
