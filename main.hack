namespace Lexidor\HHClientOptions;

<<__EntryPoint>>
async function main_async(): Awaitable<void> {
  require_once __DIR__.'/vendor/autoload.hack';
  \Facebook\AutoloadMap\initialize();

  echo "Read README.md, found at the root of this repository.";
}
