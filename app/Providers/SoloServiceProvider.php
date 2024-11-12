<?php

namespace App\Providers;

use AaronFrancis\Solo\Commands\EnhancedTailCommand;
use AaronFrancis\Solo\Facades\Solo;
use AaronFrancis\Solo\Providers\SoloApplicationServiceProvider;

class SoloServiceProvider extends SoloApplicationServiceProvider
{
    public function register()
    {
        Solo::useTheme('dark')
            // Commands that auto start.
            ->addCommands([
                EnhancedTailCommand::make('Logs', 'tail -f -n 100 ' . storage_path('logs/laravel.log')),
                'Pail' => 'sail art pail --timeout=0',
                'Vite' => 'sail yarn run dev',
                // 'HTTP' => 'php artisan serve',
            ])
            // Not auto-started
            ->addLazyCommands([
                'Queue' => 'sail art queue:listen --tries=1',
                // 'Reverb' => 'php artisan reverb:start',
                // 'Pint' => 'pint --ansi',
            ])
            // FQCNs of trusted classes that can add commands.
            ->allowCommandsAddedFrom([
                //
            ]);
    }

    public function boot()
    {
        //
    }
}
