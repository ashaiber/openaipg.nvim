# openaipg.nvim

A simple OpenAI Playground plugin for Neovim.

Allows to put text between:

```
% Prompt

[test]

% End of prompt
```

And then run :SendToOpenAI to send the text to OpenAI Playground and print the response after the end of the prompt,
retaining previous versions.

## Installation

Using Packer:

```lua
use 'ashaiber/openaipg.nvim'

require('openaipg').setup {
}
```

Note that `curl` must be installed, and the OpenAI key must be set as an environment variable.

## Configuring the model to use

The default model is gpt-3.5-turbo. To change it, use the `model` option in the prompt file itself:

```
---
model: gpt-4-0125-preview
---

% Prompt
...
```
