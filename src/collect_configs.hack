namespace Lexidor\HHClientOptions {

  use namespace HH\Lib\{C, Keyset, Str, Vec};
  use type HH\Lib\Ref;

  <<__EntryPoint>>
  function main_collect_configs(): void {
    require_once __DIR__.'/../vendor/autoload.hack';
    \Facebook\AutoloadMap\initialize();

    $is_comment = _Private\is_comment<>;
    $get_lines = _Private\file_get_lines<>;
    $is_blank = Str\is_empty<>;
    $to_pair = _Private\to_pair<>;
    $is_applicable_option = _Private\is_applicable_option<>;
        
    $format = _Private\format<>;
    $assert_no_contradiction = _Private\assert_no_contradiction<>;

    $options = _Private\get_config_files()
      |> Vec\map($$, $get_lines)
      |> Keyset\flatten($$)
      |> Keyset\filter($$, and(not($is_comment), not($is_blank)))
      |> Keyset\sort($$)
      |> Vec\map($$, $to_pair)
      |> Vec\filter($$, $is_applicable_option)
      |> Vec\unique_by($$, $option ==> $option[0].'='.$option[1])
      |> $assert_no_contradiction($$)
      |> Vec\map($$, $format)
      |> Str\join($$, \PHP_EOL);

    echo $options.\PHP_EOL;
  }

  function not<T>((function(T): bool) $func): (function(T): bool) {
    return $x ==> !$func($x);
  }

  function and<T>(
    (function(T): bool) $a,
    (function(T): bool) $b,
  ): (function(T): bool) {
    return $x ==> $a($x) && $b($x);
  }

  namespace _Private {

    function is_comment(string $option): bool {
      return Str\starts_with($option, ';') || Str\starts_with($option, '#');
    }

    function to_pair(string $option): (string, string) {
      $assert_valid_option = expect($pair ==> C\count($pair) === 2);
      $trim = Str\trim<>;

      return Str\split($option, '=')
        |> $assert_valid_option($$)
        |> Vec\map($$, $trim)
        |> tuple($$[0], $$[1]);
    }

    function format((string, string) $option): string {
      return Str\format('%s = %s', $option[0], $option[1]);
    }

    const keyset<string> UNAPPLICABLE_OPTIONS = keyset['ignored_paths'];

    function is_applicable_option((string, string) $option): bool {
      return !C\contains(UNAPPLICABLE_OPTIONS, $option[0]) &&
        C\contains(keyset['true', 'false'], $option[1]);
    }

    function assert_no_contradiction(
      vec<(string, string)> $options,
    ): vec<(string, string)> {
      $options_seen_before = new Ref(keyset[]);
      $have_seen_before = $option ==> {
        if (C\contains($options_seen_before->value, $option)) {
          return true;
        }
        $options_seen_before->value[] = $option;
        return false;
      };

      $contradiction = Vec\map($options, $option ==> $option[0])
        |> C\find($$, $have_seen_before);

      if ($contradiction is nonnull) {
        $errors = Vec\filter($options, $opt ==> $opt[0] === $contradiction);

        throw new \InvalidArgumentException(Str\format(
          'Setting %s has been found to have the values "%s" and "%s"',
          $contradiction,
          $errors[0][1],
          $errors[1][1],
        ));
      }

      return $options;
    }

    function expect<T>((function(T): bool) $assertion): (function(T): T) {
      return $x ==> {
        invariant($assertion($x), 'Assertion failed!');
        return $x;
      };
    }

    function file_get_lines(string $path): vec<string> {
      $contents = \file_get_contents($path);
      if ($contents === false) {
        throw new \RuntimeException(
          Str\format('File at: %s could not be loaded', $path),
        );
      }
      return Str\split($contents, \PHP_EOL);
    }

    function get_config_files(): vec<string> {
      $output = '';
      $error_code = -1;
      \exec(<<<'SH'
for f in $(find -name '.hhconfig'); do 
  echo $f
done
SH
      ,
      inout $output,
      inout $error_code,
      );

      if ($error_code !== 0) {
        echo "Dependency failed!";
        exit($error_code);
      }
      return vec($output);
    }
  }
}
