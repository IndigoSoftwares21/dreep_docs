#!/bin/bash
mkdir -p api-reference/upload
mkdir -p api-reference/media
mkdir -p api-reference/folders
mkdir -p api-reference/presets

cat << 'YAML' > openapi.yaml
openapi: 3.0.0
info:
  title: Dreep API
  description: The universal media processing and storage API.
  version: 1.0.0
servers:
  - url: https://api.dreep.cloud
components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
security:
  - ApiKeyAuth: []
paths:
  /api/v1/upload:
    post:
      summary: Upload Media
      description: Upload a media file. You can optionally apply initial transforms by passing a JSON string in the transform field.
      tags:
        - Upload
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                file:
                  type: string
                  format: binary
                  description: The media file to upload.
                transform:
                  type: string
                  description: 'JSON string representing initial transforms to apply (e.g. {"width": 1200, "format": "webp"}).'
              required:
                - file
      responses:
        '200':
          description: Media uploaded successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: string
                  url:
                    type: string
                  size:
                    type: integer
                  format:
                    type: string
  /api/v1/fetch/{mediaId}:
    get:
      summary: Fetch Media
      description: Get an asset by ID, applying optional transforms on the fly.
      tags:
        - Media
      parameters:
        - name: mediaId
          in: path
          required: true
          schema:
            type: string
        - name: transforms
          in: query
          description: JSON encoded string or preset ID to apply transforms before fetching.
          schema:
            type: string
      responses:
        '200':
          description: Media binary content
          content:
            image/*:
              schema:
                type: string
                format: binary
  /api/v1/media:
    get:
      summary: List Media Assets
      tags:
        - Media
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: A list of media assets
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id:
                      type: string
                    filename:
                      type: string
                    url:
                      type: string
  /api/v1/media/{mediaId}:
    delete:
      summary: Delete Media Asset
      tags:
        - Media
      parameters:
        - name: mediaId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Asset deleted successfully
  /api/v1/folders:
    get:
      summary: List Folders
      tags:
        - Folders
      responses:
        '200':
          description: A list of folders
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id:
                      type: string
                    name:
                      type: string
    post:
      summary: Create Folder
      tags:
        - Folders
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                name:
                  type: string
                parentId:
                  type: string
              required:
                - name
      responses:
        '200':
          description: Folder created
  /api/v1/presets:
    get:
      summary: List Presets
      tags:
        - Presets
      responses:
        '200':
          description: A list of transform presets
    post:
      summary: Create Preset
      tags:
        - Presets
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                name:
                  type: string
                operations:
                  type: array
                  items:
                    type: object
              required:
                - name
                - operations
      responses:
        '200':
          description: Preset created
  /api/v1/presets/{id}:
    delete:
      summary: Delete Preset
      tags:
        - Presets
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Preset deleted
YAML

cat << 'MDX' > api-reference/upload/upload-media.mdx
---
title: "Upload Media"
openapi: "POST /api/v1/upload"
---
MDX

cat << 'MDX' > api-reference/media/fetch-media.mdx
---
title: "Fetch Media"
openapi: "GET /api/v1/fetch/{mediaId}"
---
MDX

cat << 'MDX' > api-reference/media/list-media.mdx
---
title: "List Media Assets"
openapi: "GET /api/v1/media"
---
MDX

cat << 'MDX' > api-reference/media/delete-media.mdx
---
title: "Delete Media Asset"
openapi: "DELETE /api/v1/media/{mediaId}"
---
MDX

cat << 'MDX' > api-reference/folders/list-folders.mdx
---
title: "List Folders"
openapi: "GET /api/v1/folders"
---
MDX

cat << 'MDX' > api-reference/folders/create-folder.mdx
---
title: "Create Folder"
openapi: "POST /api/v1/folders"
---
MDX

cat << 'MDX' > api-reference/presets/list-presets.mdx
---
title: "List Presets"
openapi: "GET /api/v1/presets"
---
MDX

cat << 'MDX' > api-reference/presets/create-preset.mdx
---
title: "Create Preset"
openapi: "POST /api/v1/presets"
---
MDX

cat << 'MDX' > api-reference/presets/delete-preset.mdx
---
title: "Delete Preset"
openapi: "DELETE /api/v1/presets/{id}"
---
MDX

cat << 'JSON' > docs.json
{
  "$schema": "https://mintlify.com/docs.json",
  "theme": "mint",
  "name": "Dreep API Documentation",
  "colors": {
    "primary": "#10B981",
    "light": "#34D399",
    "dark": "#059669"
  },
  "favicon": "/favicon.svg",
  "openapi": "openapi.yaml",
  "navigation": {
    "pages": [
      {
        "group": "Getting Started",
        "pages": [
          "index",
          "quickstart"
        ]
      },
      {
        "group": "Upload",
        "pages": [
          "api-reference/upload/upload-media"
        ]
      },
      {
        "group": "Media",
        "pages": [
          "api-reference/media/fetch-media",
          "api-reference/media/list-media",
          "api-reference/media/delete-media"
        ]
      },
      {
        "group": "Folders",
        "pages": [
          "api-reference/folders/create-folder",
          "api-reference/folders/list-folders"
        ]
      },
      {
        "group": "Presets",
        "pages": [
          "api-reference/presets/create-preset",
          "api-reference/presets/list-presets",
          "api-reference/presets/delete-preset"
        ]
      }
    ]
  },
  "logo": {
    "light": "/logo/light.svg",
    "dark": "/logo/dark.svg"
  },
  "navbar": {
    "links": [
      {
        "label": "Support",
        "href": "mailto:info@fufusoftwareslimited.org"
      }
    ],
    "primary": {
      "type": "button",
      "label": "Website",
      "href": "https://dreep.cloud"
    }
  },
  "contextual": {
    "options": [
      "copy",
      "view"
    ]
  }
}
JSON

chmod +x setup_docs.sh
./setup_docs.sh
