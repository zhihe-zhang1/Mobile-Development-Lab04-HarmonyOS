from pathlib import Path
import json, re, subprocess, sys, tempfile, unittest

root = Path(sys.argv.pop(1)).resolve()
app = root / 'entry/src/main'
ets = app / 'ets'
profile = app / 'resources/base/profile'

class NativeProjectChecks(unittest.TestCase):
    def read_json(self, path):
        return json.loads(path.read_text())

    def test_project_main_and_destination_routes(self):
        module = self.read_json(app / 'module.json5')['module']
        self.assertEqual(module['pages'], '$profile:main_pages')
        self.assertEqual(module['routerMap'], '$profile:router_map')
        root_page, = self.read_json(profile / 'main_pages.json')['src']
        self.assertEqual(root_page, 'pages/Index')
        self.assertTrue((ets / (root_page + '.ets')).is_file())
        entry = module['abilities'][0]['srcEntry']
        self.assertIn("loadContent('pages/Index'", (app / entry).read_text())
        route, = self.read_json(profile / 'router_map.json')['routerMap']
        self.assertEqual(route['name'], 'ProductDetail')
        detail = (root / 'entry' / route['pageSourceFile']).read_text()
        self.assertIn('export function ' + route['buildFunction'], detail)
        self.assertIn('context.pathInfo.param', detail)

    def test_route_stack_result_and_tabs_are_separate(self):
        index = (ets / 'pages/Index.ets').read_text()
        detail = (ets / 'pages/ProductDetail.ets').read_text()
        listing = (ets / 'components/ProductList.ets').read_text()
        self.assertRegex(listing, r'\.onClick\(\(\)\s*=>\s*\{\s*this\.onProductClick\(product\)')
        self.assertIn('new DetailRequest(product.id', index)
        self.assertRegex(index, r'pushPathByName\(PRODUCT_DETAIL_ROUTE, request, \(info: PopInfo\)')
        self.assertIn('info.result', index)
        self.assertIn('applyFavoriteResult', index)
        self.assertIn('pathStack.pop(result)', detail)
        self.assertIn('pathStack?.pop()', detail)
        self.assertEqual(index.count('TabContent()'), 2)
        self.assertIn('tabController.changeIndex(', index)
        self.assertNotIn('pushPathByName', detail)

    def test_resources_and_sdk_profile(self):
        build = self.read_json(root / 'build-profile.json5')
        product, = build['app']['products']
        self.assertEqual(product['runtimeOS'], 'HarmonyOS')
        self.assertEqual(build['app']['signingConfigs'], [])
        self.assertEqual(build['modules'][0]['srcPath'], './entry')
        for s in ['hvigorfile.ts', 'hvigor/hvigor-config.json5', 'entry/hvigorfile.ts', 'oh-package.json5', 'entry/oh-package.json5']:
            self.assertTrue((root / s).is_file(), s)
        for s in ['AppScope/resources/base/media/app_icon.png', 'entry/src/main/resources/base/media/start_icon.png']:
            self.assertTrue((root/s).read_bytes().startswith(b'\x89PNG\r\n\x1a\n'), s)
        self.assertNotIn('HBuilderX', (root / 'oh-package.json5').read_text())

    def test_catalog_logic(self):
        catalog = (ets / 'model/Catalog.ets').read_text()
        with tempfile.TemporaryDirectory() as d:
            p = Path(d)
            (p / 'Catalog.mts').write_text(catalog)
            (p / 'catalog.test.mjs').write_text(Path(__file__).with_name('catalog.test.mjs').read_text())
            result = subprocess.run(['node','--test','catalog.test.mjs'], cwd=p, text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            print(result.stdout)

if __name__ == '__main__':
    unittest.main(verbosity=2)
