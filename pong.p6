use v6;
use NativeCall;
use SDL2::Raw;

constant WIDTH = 800;
constant HEIGHT = 600;

constant BALL_WIDTH = 10;
constant BALL_HEIGHT = 10;
constant BALL_START_X = (WIDTH / 2) - (BALL_WIDTH / 2);
constant BALL_START_Y = (HEIGHT / 2) - (BALL_HEIGHT / 2);

constant K_UP = 82;
constant K_DOWN = 81;

constant MAX_FPS = 60;
constant TIME_PER_FRAME = 1 / MAX_FPS;

constant PADDLE_WIDTH = 4;
constant PADDLE_HEIGHT = (HEIGHT / 10).round;
constant PADDLE_MARGIN_LEFT = 10;
constant PADDLE_MARGIN_RIGHT = WIDTH - PADDLE_WIDTH - PADDLE_WIDTH;

constant PADDLE_MOVE_SPEED = 240;
constant PADDLE_BOTTOM_Y = HEIGHT - PADDLE_HEIGHT;


my $bg_rect = SDL_Rect.new( 0, 0, WIDTH, HEIGHT );
my $paddle1_rect = SDL_Rect.new(
    PADDLE_MARGIN_LEFT,
    (HEIGHT / 2) - (PADDLE_HEIGHT / 2),
    PADDLE_WIDTH, PADDLE_HEIGHT,
);
my $paddle2_rect = SDL_Rect.new(
    PADDLE_MARGIN_RIGHT,
    (HEIGHT / 2) - (PADDLE_HEIGHT / 2),
    PADDLE_WIDTH, PADDLE_HEIGHT,
);
my $ball_rect = SDL_Rect.new(
    BALL_START_X, BALL_START_Y,
    BALL_WIDTH, BALL_HEIGHT,
);

my $move_down = 0;
my $move_up = 0;


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
    my Duration $last_elapsed_time;

    loop {
        my $start_frame = now;

        return if ! poll_events();
        update_location( $last_elapsed_time ) if $last_elapsed_time;
        update_drawing( $window, $render );

        my $end_frame = now;
        $last_elapsed_time = $end_frame - $start_frame;
        if $last_elapsed_time < TIME_PER_FRAME {
            my $sleep_time = TIME_PER_FRAME - $last_elapsed_time;
            sleep( $sleep_time );
        }
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
            when *.type == KEYDOWN {
                my $key = .scancode;
                if $key == K_UP {
                    $move_up = 1;
                }
                elsif $key == K_DOWN {
                    $move_down = 1;
                }
            }
            when *.type == KEYUP {
                my $key = .scancode;
                if $key == K_UP {
                    $move_up = 0;
                }
                elsif $key == K_DOWN {
                    $move_down = 0;
                }
            }
        }
    }

    return 1;
}

sub update_location( Duration $elapsed_time )
{
    my Int $paddle_move = (PADDLE_MOVE_SPEED * $elapsed_time).round();

    if $move_up {
        $paddle1_rect.y = $paddle1_rect.y - $paddle_move;
        $paddle1_rect.y = 0 if $paddle1_rect.y < 0
    }
    if $move_down {
        $paddle1_rect.y = $paddle1_rect.y + $paddle_move;
        $paddle1_rect.y = PADDLE_BOTTOM_Y if $paddle1_rect.y > PADDLE_BOTTOM_Y;
    }
}

sub update_drawing( $window, $render )
{
    SDL_RenderClear( $render );

    SDL_SetRenderDrawColor( $render, 0, 0, 0, 255 );
    SDL_RenderFillRect( $render, $bg_rect );

    SDL_SetRenderDrawColor( $render, 255, 0, 0, 255 );
    SDL_RenderFillRect( $render, $paddle1_rect );
    SDL_RenderFillRect( $render, $paddle2_rect );

    SDL_SetRenderDrawColor( $render, 0, 255, 0, 255 );
    SDL_RenderFillRect( $render, $ball_rect );

    SDL_RenderPresent( $render );
    return;
}


{
    my ($window, $render) = init();

    say "Starting main loop";
    main_loop( $window, $render );
    say "Done with main loop";
}

SDL_Quit();
