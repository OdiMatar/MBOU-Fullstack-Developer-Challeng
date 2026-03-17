<?php

namespace App\Http\Controllers;

use App\Models\Purchase;
use App\Models\Item;
use Illuminate\Http\Request;

class PurchaseController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'item_id' => 'required|exists:items,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $item = Item::find($validated['item_id']);

        if ($item->stock < $validated['quantity']) {
            return response()->json([
                'success' => false,
                'message' => 'Niet genoeg voorraad beschikbaar'
            ], 400);
        }

        $totalPrice = $item->price * $validated['quantity'];

        $purchase = Purchase::create([
            'user_id' => $validated['user_id'],
            'item_id' => $validated['item_id'],
            'quantity' => $validated['quantity'],
            'total_price' => $totalPrice,
            'status' => 'completed',
        ]);

        // Update voorraad
        $item->stock -= $validated['quantity'];
        $item->save();

        return response()->json([
            'success' => true,
            'message' => 'Aankoop succesvol!',
            'purchase' => $purchase,
        ], 201);
    }

    public function getUserPurchases($userId)
    {
        $purchases = Purchase::where('user_id', $userId)
            ->with('item')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $purchases
        ]);
    }
}
