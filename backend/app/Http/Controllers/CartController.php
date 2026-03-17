<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\Item;
use App\Models\Purchase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CartController extends Controller
{
    private function calculateLineTotal(Cart $cartItem): float
    {
        $price = (float) ($cartItem->item->price ?? 0);
        return $price * $cartItem->quantity;
    }

    public function index($userId)
    {
        $cartItems = Cart::with('item')
            ->where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get();

        $total = $cartItems->sum(fn ($cartItem) => $this->calculateLineTotal($cartItem));

        return response()->json([
            'success' => true,
            'data' => $cartItems,
            'total' => round($total, 2),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'item_id' => 'required|exists:items,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $item = Item::findOrFail($validated['item_id']);
        $requestedQuantity = $validated['quantity'];

        $cartItem = Cart::where('user_id', $validated['user_id'])
            ->where('item_id', $validated['item_id'])
            ->first();

        $newQuantity = ($cartItem?->quantity ?? 0) + $requestedQuantity;

        if (($item->stock ?? 0) < $newQuantity) {
            return response()->json([
                'success' => false,
                'message' => 'Niet genoeg voorraad beschikbaar',
            ], 400);
        }

        if ($cartItem) {
            $cartItem->update(['quantity' => $newQuantity]);
        } else {
            $cartItem = Cart::create([
                'user_id' => $validated['user_id'],
                'item_id' => $validated['item_id'],
                'quantity' => $requestedQuantity,
            ]);
        }

        $cartItem->load('item');

        return response()->json([
            'success' => true,
            'message' => 'Toegevoegd aan winkelwagen',
            'data' => $cartItem,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $cartItem = Cart::with('item')->find($id);

        if (!$cartItem) {
            return response()->json([
                'success' => false,
                'message' => 'Winkelwagen item niet gevonden',
            ], 404);
        }

        $validated = $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        if (($cartItem->item->stock ?? 0) < $validated['quantity']) {
            return response()->json([
                'success' => false,
                'message' => 'Niet genoeg voorraad beschikbaar',
            ], 400);
        }

        $cartItem->update(['quantity' => $validated['quantity']]);

        return response()->json([
            'success' => true,
            'message' => 'Aantal bijgewerkt',
            'data' => $cartItem->load('item'),
        ]);
    }

    public function destroy($id)
    {
        $cartItem = Cart::find($id);

        if (!$cartItem) {
            return response()->json([
                'success' => false,
                'message' => 'Winkelwagen item niet gevonden',
            ], 404);
        }

        $cartItem->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item verwijderd uit winkelwagen',
        ]);
    }

    public function checkout(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
        ]);

        $cartItems = Cart::with('item')
            ->where('user_id', $validated['user_id'])
            ->get();

        if ($cartItems->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Je winkelwagen is leeg',
            ], 400);
        }

        $createdPurchases = [];
        $grandTotal = 0;

        try {
            DB::transaction(function () use ($cartItems, $validated, &$createdPurchases, &$grandTotal) {
                foreach ($cartItems as $cartItem) {
                    $item = Item::lockForUpdate()->find($cartItem->item_id);

                    if (!$item || ($item->stock ?? 0) < $cartItem->quantity) {
                        throw new \RuntimeException('Niet genoeg voorraad voor: ' . ($cartItem->item->name ?? 'onbekend item'));
                    }

                    $lineTotal = ((float) ($item->price ?? 0)) * $cartItem->quantity;
                    $grandTotal += $lineTotal;

                    $purchase = Purchase::create([
                        'user_id' => $validated['user_id'],
                        'item_id' => $item->id,
                        'quantity' => $cartItem->quantity,
                        'total_price' => $lineTotal,
                        'status' => 'completed',
                    ]);

                    $item->stock -= $cartItem->quantity;
                    $item->save();

                    $createdPurchases[] = $purchase->load('item');
                }

                Cart::where('user_id', $validated['user_id'])->delete();
            });
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Aankoop succesvol afgerond',
            'data' => $createdPurchases,
            'total' => round($grandTotal, 2),
        ]);
    }
}
