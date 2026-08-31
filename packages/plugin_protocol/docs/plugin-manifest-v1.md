# Plugin Manifest v1

The plugin manifest describes a Shinga plugin without executing its code. It identifies the plugin, declares the Plugin API version it targets, specifies its interpreted-Dart entry point, requests permissions, and defines user-configurable settings.

## Complete Example

```json
{
  "manifestVersion": 1,
  "id": "dev.shinga.mangafoo",
  "name": "MangaFoo",
  "version": "1.0.0",
  "pluginApiVersion": 1,
  "entry": "dist/index.dart",
  "icon": "https://mangafoo.test/favicon.png",
  "permissions": {
    "network": {
      "hosts": [
        "api.mangafoo.test",
        "*.cdn.mangafoo.test"
      ]
    }
  },
  "settings": [
    {
      "id": "searchPrefix",
      "type": "text",
      "label": {
        "en": "Search prefix",
        "ru": "Префикс поиска"
      },
      "defaultValue": ""
    },
    {
      "id": "apiToken",
      "type": "secret",
      "required": true,
      "label": {
        "en": "API token",
        "ru": "API-токен"
      },
      "description": {
        "en": "Required to authenticate with the **MangaFoo API**.",
        "ru": "Требуется для аутентификации в **MangaFoo API**."
      }
    },
    {
      "id": "adultContent",
      "type": "boolean",
      "label": {
        "en": "Adult content",
        "ru": "Контент 18+"
      },
      "defaultValue": false
    },
    {
      "id": "minimumRating",
      "type": "num",
      "label": {
        "en": "Minimum rating",
        "ru": "Минимальный рейтинг"
      },
      "defaultValue": 7.5
    },
    {
      "id": "contentLanguage",
      "type": "select",
      "required": true,
      "label": {
        "en": "Content language",
        "ru": "Язык контента"
      },
      "defaultValue": "en",
      "options": [
        {
          "value": "en",
          "label": {
            "en": "English",
            "ru": "Английский"
          }
        },
        {
          "value": "ru",
          "label": {
            "en": "Russian",
            "ru": "Русский"
          }
        }
      ]
    },
    {
      "id": "genres",
      "type": "multiSelect",
      "label": {
        "en": "Preferred genres",
        "ru": "Предпочитаемые жанры"
      },
      "defaultValue": [
        "action"
      ],
      "options": [
        {
          "value": "action",
          "label": {
            "en": "Action",
            "ru": "Боевик"
          }
        },
        {
          "value": "comedy",
          "label": {
            "en": "Comedy",
            "ru": "Комедия"
          }
        }
      ]
    }
  ]
}
```

## Root Object

| Field | JSON type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `manifestVersion` | integer | Yes | - | Manifest schema version. Must be exactly `1` for this format. |
| `id` | string | Yes | - | Globally unique plugin identifier in lowercase reverse-DNS form. |
| `name` | string | Yes | - | User-facing plugin name. Must not be empty or whitespace-only. |
| `version` | string | Yes | - | Plugin package version using Semantic Versioning 2.0.0. |
| `pluginApiVersion` | integer | Yes | - | Positive Plugin API version required by the plugin. |
| `entry` | string | No | `index.dart` | Package-relative path to the interpreted-Dart entry point. |
| `icon` | string | No | No icon | Absolute HTTP or HTTPS image URL shown for the plugin in the UI. |
| `permissions` | object | No | No permissions | Capabilities requested by the plugin. |
| `settings` | array of objects | No | Empty array | Static user-configurable setting definitions. |

Unknown root fields produce warnings. They do not invalidate an otherwise valid v1 manifest.

### Plugin ID

The `id` field uses a lowercase reverse-DNS identifier such as `dev.shinga.mangafoo` or `com.example.source`.

Rules:

- It must contain at least two dot-separated segments.
- Its total length must not exceed 253 characters.
- Each segment must be 1 to 63 characters long.
- Segments may contain lowercase ASCII letters, digits, and interior hyphens.
- A segment must not begin or end with a hyphen.
- Uppercase and non-ASCII characters are not accepted.

### Plugin Version

The `version` field must follow [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

Valid examples include `1.0.0`, `1.2.3-alpha.1`, and `2.0.0+build.5`. Prefixes such as `v1.0.0` and numeric identifiers with invalid leading zeroes are rejected.

### Plugin API Version

`pluginApiVersion` must be a positive integer. Manifest parsing does not compare it with the API versions supported by the current application. Compatibility is checked separately by the plugin host.

### Entry Path

`entry` is a syntactically safe, package-relative path.

Rules:

- It must end with the case-sensitive `.dart` extension.
- It must be relative and use `/` as the path separator.
- Absolute paths, Windows drive paths, URLs, colons, backslashes, and null bytes are rejected.
- Empty path segments and `.` or `..` segments are rejected.
- Windows device names, trailing dots or spaces, control characters, and the characters `<`, `>`, `"`, `|`, `?`, and `*` are rejected in every segment.

### Icon

The optional `icon` image is shown for the plugin in the UI. Developers may use the parsed site's favicon or provide their own image URL.

Rules:

- The value must be an absolute HTTP or HTTPS URL with a non-empty host.
- The URL path must end, case-insensitively, in `.ico`, `.gif`, `.webp`, `.png`, `.jpg`, `.jpeg`, `.avif`, `.bmp`, `.svg`, `.svgz`, `.tif`, `.tiff`, or `.apng`.

## Localized Text

Labels and setting descriptions are localized-text objects. Each key is a locale tag and each value is the corresponding source string:

```json
{
  "en": "Content language",
  "ru": "Язык контента",
  "zh-Hans-CN": "内容语言"
}
```

Rules:

- The object must contain at least one entry.
- Every value must be a string that is not empty or whitespace-only.
- Locale tags use the supported `language[-Script][-REGION]` subset.
- `language` contains 2 to 8 ASCII letters.
- `Script`, when present, contains exactly 4 ASCII letters.
- `REGION`, when present, contains either 2 ASCII letters or 3 digits.
- Subtags are separated with `-`; underscore separators are not accepted.

Locale tags are normalized as follows:

- Language is lowercase: `EN` becomes `en`.
- Script is title case: `hans` becomes `Hans`.
- Alphabetic region is uppercase: `us` becomes `US`.
- Numeric region is preserved: `419` remains `419`.

Two source keys that become equal after normalization are invalid. For example, `EN` and `en` cannot appear in the same localized-text object.

Setting description values contain Markdown source and are limited to 4000 user-perceived Unicode grapheme clusters per locale, inclusive. Other localized-text fields, including setting and option labels, do not have this field-specific limit. The parser preserves description source exactly and does not validate Markdown syntax, normalize it, parse it, or render it.

Hosts that choose to render a setting description must use a safe Markdown profile: raw HTML, images, and interactive content are unsupported, and links are not opened.

## Permissions

The optional `permissions` object declares capabilities requested by the plugin. Manifest v1 supports only the `network` permission.

If `permissions` is absent, or if it does not contain `network`, the plugin has no network access. Unknown permission names are errors rather than warnings.

```json
{
  "permissions": {
    "network": {
      "hosts": [
        "api.example.com",
        "*.cdn.example.com"
      ]
    }
  }
}
```

### Network Permission

| Field | JSON type | Required | Description |
| --- | --- | --- | --- |
| `hosts` | array of strings | Yes | Exact and wildcard host patterns the plugin may access. |

The `hosts` array may be empty, in which case the network permission grants access to no hosts. Duplicate patterns are rejected after lowercase normalization. Exact and wildcard forms for the same base host are different patterns and may both be declared.

Unknown fields inside `network` produce warnings.

### Host Patterns

Host patterns are ASCII hostnames. They are normalized to lowercase and must not contain a scheme, port, path, query, fragment, or user information.

A wildcard pattern begins with `*.` and matches one or more subdomain levels. It does not match the base host itself.

Manifest v1 does not provide an allow-all network pattern. Plugins should request only the specific hosts they require.

## Settings

The optional `settings` array declares static settings that Shinga can render without starting the plugin runtime. The resulting values are exposed to plugin code through `context.settings`.

Every setting contains the following common fields:

| Field | JSON type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `id` | string | Yes | - | Setting identifier used by plugin code. Must not be empty or whitespace-only. |
| `type` | string | Yes | - | One of `text`, `secret`, `boolean`, `num`, `select`, or `multiSelect`. |
| `label` | localized text | Yes | - | User-facing setting label. |
| `description` | localized Markdown text | No | No description | Developer-provided explanation of why the setting is needed. Each locale value is limited to 4000 grapheme clusters. |
| `required` | boolean | No | `false` | Whether the user must provide a value. |

Setting IDs must be unique within the manifest. ID comparison is case-sensitive. Unknown setting types are errors. Unknown fields in a known setting definition produce warnings.

The `required` flag does not make `defaultValue` mandatory. A required setting may still require explicit user input.

### Text

A `text` setting stores a regular string.

| Field | JSON type | Required | Default |
| --- | --- | --- | --- |
| `defaultValue` | string | No | No default |

```json
{
  "id": "searchPrefix",
  "type": "text",
  "label": {
    "en": "Search prefix"
  },
  "defaultValue": "manga:"
}
```

An empty string is a valid text default.

### Secret

A `secret` setting stores sensitive text such as an API token or password. The application is expected to obscure it in the UI and store it separately from ordinary settings.

```json
{
  "id": "apiToken",
  "type": "secret",
  "required": true,
  "label": {
    "en": "API token"
  }
}
```

`defaultValue` is forbidden for secret settings, including `null` or an empty string. Secrets must be supplied by the user or another trusted runtime mechanism.

### Boolean

A `boolean` setting stores a boolean value.

| Field | JSON type | Required | Default |
| --- | --- | --- | --- |
| `defaultValue` | boolean | No | `false` |

```json
{
  "id": "adultContent",
  "type": "boolean",
  "label": {
    "en": "Adult content"
  },
  "defaultValue": false
}
```

### Number

A `num` setting stores a finite JSON number. Both integer and fractional JSON numbers are accepted.

| Field | JSON type | Required | Default |
| --- | --- | --- | --- |
| `defaultValue` | number | No | No default |

```json
{
  "id": "minimumRating",
  "type": "num",
  "label": {
    "en": "Minimum rating"
  },
  "defaultValue": 7.5
}
```

### Select

A `select` setting stores one value from a fixed option list.

| Field | JSON type | Required | Default |
| --- | --- | --- | --- |
| `options` | array of option objects | Yes | - |
| `defaultValue` | string | No | No default |

Rules:

- `options` must contain at least one option.
- Option values must be unique within the setting.
- If `defaultValue` is present, it must exactly equal one declared option value.

```json
{
  "id": "contentLanguage",
  "type": "select",
  "label": {
    "en": "Content language"
  },
  "defaultValue": "en",
  "options": [
    {
      "value": "en",
      "label": {
        "en": "English"
      }
    },
    {
      "value": "ru",
      "label": {
        "en": "Russian"
      }
    }
  ]
}
```

### Multi-select

A `multiSelect` setting stores zero or more values from a fixed option list.

| Field | JSON type | Required | Default |
| --- | --- | --- | --- |
| `options` | array of option objects | Yes | - |
| `defaultValue` | array of strings | No | No default |

Rules:

- `options` must contain at least one option.
- Option values must be unique within the setting.
- Every default value must exactly equal a declared option value.
- Default values must not contain duplicates.
- An empty default array is valid.

```json
{
  "id": "genres",
  "type": "multiSelect",
  "label": {
    "en": "Preferred genres"
  },
  "defaultValue": [
    "action",
    "comedy"
  ],
  "options": [
    {
      "value": "action",
      "label": {
        "en": "Action"
      }
    },
    {
      "value": "comedy",
      "label": {
        "en": "Comedy"
      }
    }
  ]
}
```

### Option Objects

Select and multi-select settings use the same option structure:

| Field | JSON type | Required | Description |
| --- | --- | --- | --- |
| `value` | string | Yes | Internal value exposed to plugin code. Must not be empty or whitespace-only. |
| `label` | localized text | Yes | User-facing option label. |

Option value comparison is case-sensitive. Unknown option fields produce warnings.
