const fs = require('fs');
const yaml = require('yaml');

const specStr = fs.readFileSync('openapi.yaml', 'utf8');
const spec = yaml.parse(specStr);

spec.components.schemas = {
    ErrorResponse: {
        type: 'object',
        properties: {
            message: { type: 'string', example: 'An error occurred' },
            code: { type: 'integer', example: 400 },
            validationErrors: {
                type: 'array',
                items: {
                    type: 'object',
                    properties: {
                        path: { type: 'array', items: { type: 'string' } },
                        message: { type: 'string' }
                    }
                }
            }
        }
    }
};

const wrapData = (schema) => ({
    type: 'object',
    properties: {
        message: { type: 'string', example: 'Success' },
        code: { type: 'integer', example: 200 },
        data: schema
    }
});

for (const resp of ['BadRequest', 'Unauthorized', 'NotFound', 'InternalError']) {
    if (spec.components.responses[resp]) {
        spec.components.responses[resp].content['application/json'].schema = { $ref: '#/components/schemas/ErrorResponse' };
    }
}

for (const path in spec.paths) {
    for (const method in spec.paths[path]) {
        const op = spec.paths[path][method];
        
        // Wrap 200 responses if they return JSON
        if (op.responses['200'] && op.responses['200'].content && op.responses['200'].content['application/json']) {
            const oldSchema = op.responses['200'].content['application/json'].schema;
            op.responses['200'].content['application/json'].schema = wrapData(oldSchema);
        }

        // Add code samples
        const curlCmd = method === 'get' 
            ? `curl -X GET "https://api.dreep.cloud${path}" -H "x-api-key: sk_live_xxxxx"`
            : method === 'delete'
            ? `curl -X DELETE "https://api.dreep.cloud${path}" -H "x-api-key: sk_live_xxxxx"`
            : path === '/api/v1/upload'
            ? `curl -X POST "https://api.dreep.cloud/api/v1/upload" \\\n  -H "x-api-key: sk_live_xxxxx" \\\n  -F "file=@hero.jpg" \\\n  -F "transform={\\"width\\":1200}"`
            : `curl -X ${method.toUpperCase()} "https://api.dreep.cloud${path}" \\\n  -H "x-api-key: sk_live_xxxxx" \\\n  -H "Content-Type: application/json" \\\n  -d '{"name":"Example"}'`;

        let axiosCode = '';
        if (path === '/api/v1/upload') {
            axiosCode = `const axios = require('axios');\nconst FormData = require('form-data');\nconst fs = require('fs');\n\nconst formData = new FormData();\nformData.append('file', fs.createReadStream('./hero.jpg'));\nformData.append('transform', JSON.stringify({ width: 1200 }));\n\naxios.post('https://api.dreep.cloud/api/v1/upload', formData, {\n  headers: {\n    'x-api-key': 'sk_live_xxxxx',\n    ...formData.getHeaders()\n  }\n}).then(res => console.log(res.data));`;
        } else if (method === 'get' || method === 'delete') {
            axiosCode = `const axios = require('axios');\n\naxios.${method}('https://api.dreep.cloud${path}', {\n  headers: { 'x-api-key': 'sk_live_xxxxx' }\n}).then(res => console.log(res.data));`;
        } else {
            axiosCode = `const axios = require('axios');\n\naxios.${method}('https://api.dreep.cloud${path}', { name: "Example" }, {\n  headers: { 'x-api-key': 'sk_live_xxxxx' }\n}).then(res => console.log(res.data));`;
        }

        op['x-codeSamples'] = [
            { lang: 'cURL', source: curlCmd },
            { lang: 'JavaScript (Axios)', source: axiosCode }
        ];
    }
}

fs.writeFileSync('openapi.yaml', yaml.stringify(spec));
