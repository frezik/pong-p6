use v6;
use NativeCall;
use SDL2::Raw;

constant WIDTH = 800;
constant HEIGHT = 600;

constant PADDLE_WIDTH = 4;
constant PADDLE_HEIGHT = 20;


sub init()
{
    SDL_Init( VIDEO );

    my $window = SDL_CreateWindow(
        "Pong",
        SDL_WINDOWPOS_UNDEFINED_MASK, SDL_WINDOWPOS_UNDEFINED_MASK,
        WIDTH, HEIGHT,
        OPENGL
    );
    my $render = SDL_CreateRenderer( $window, -1, ACCELERATED +| PRESENTVSYNC );
    return ($window, $render);
}

sub main_loop( $window, $render )
{
    my $bg_rect = SDL_Rect.new( 0, 0, WIDTH, HEIGHT );

    loop {
        return if ! poll_events();

        SDL_RenderClear( $render );
        SDL_SetRenderDrawColor( $render, 0, 0, 0, 255 );
        SDL_RenderFillRect( $render, $bg_rect );
        SDL_RenderPresent( $render );
    }

    return 1;
}

sub poll_events()
{
    my $event = SDL_Event.new;

    while SDL_PollEvent( $event ) {
        my $casted_event = SDL_CastEvent( $event );

        given $casted_event {
            when *.type == QUIT {
                say "Quitting";
                return;
            }
        }
    }

    return 1;
}


{
    my ($window, $render) = init();

    say "Starting main loop";
    main_loop( $window, $render );
    say "Done with main loop";
}

SDL_Quit();
