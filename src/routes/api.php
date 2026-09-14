<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\StatusController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/token', [AuthController::class, 'newToken']);
});
Route::get('/status', [StatusController::class, 'index']);