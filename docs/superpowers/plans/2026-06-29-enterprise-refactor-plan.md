# Enterprise Refactor Implementation Plan

## Phase 1: Foundation & Crash Fixes (Days 1-2)

### 1.1 Setup
- Create `v3.0-dev` branch from `main`
- Add `test/` directory structure
- Setup `flutter_test` + `mocktail`

### 1.2 F1: LinkHeader null crash
- File: `lib/src/indicator/link_indicator.dart`
- Wrap `linkKey.currentState` with null check + graceful fallback

### 1.3 F2: CustomFooter unsafe cast
- File: `lib/src/indicator/custom_indicator.dart`
- Replace `onClick as void Function()?` with proper type checking

### 1.4 F3: ClassicHeader duplicate case
- File: `lib/src/indicator/classic_indicator.dart`
- Merge duplicate `canTwoLevel` cases

## Phase 2: Stability & Boundary Fixes (Days 3-5)

### 2.1 F4: _position null access → late init
- File: `lib/src/internals/indicator_wrap.dart`
- Refactor `_position` lifecycle

### 2.2 F5: _showWater animation leak
- File: `lib/src/indicator/material_indicator.dart`
- Add `dispose()` for all controllers

### 2.3 F6: viewportExtent=0 early access
- File: `lib/src/indicator/twolevel_indicator.dart`
- Add fallback default value

### 2.4 F7: _isHide flicker
- File: `lib/src/internals/indicator_wrap.dart`
- Add `layoutExtent` check

### 2.5 F8: SpringSimulation jitter
- File: `lib/src/indicator/bezier_indicator.dart`
- Adjust spring parameters

## Phase 3: Tech Debt (Days 6-9)

### 3.1 F9: copyAncestor → copyWith
- File: `lib/src/smart_refresher.dart`
- Add `copyWith()` method
- Deprecate `RefreshConfiguration.copyAncestor`
- Update all internal usage

### 3.2 F10: runtimeType workaround
- File: `lib/src/internals/refresh_physics.dart`
- Replace with proper delegate pattern

### 3.3 F11: viewport children manipulation
- File: `lib/src/smart_refresher.dart`
- Add deprecation warning
- Prepare Sliver-based alternative

## Phase 4: Enterprise API (Days 10-12)

### 4.1 E1: RefreshController autoCleanup
- Add `autoCleanup` flag
- Auto-dispose in SmartRefresher.dispose

### 4.2 E2: copyWith chain (RefactorConfiguration)
- Implement `copyWith()` on `RefreshConfiguration`
- Update docs

### 4.3 E3: Indicator lifecycle hooks
- Add `onInitialized` / `onDisposed` to abstract class

### 4.4 E4: Stream-based status listeners
- Add `headerStatusStream` / `footerStatusStream` to RefreshController

### 4.5 E5: TwoLevel header/footer config
- Add `twoLevelHeader` / `twoLevelFooter` props to SmartRefresher

## Phase 5: Test & Polish (Days 13-15)

### 5.1 Unit tests for all fixes
### 5.2 Integration tests for enterprise APIs
### 5.3 Migration guide doc
### 5.4 CHANGELOG.md
### 5.5 Version bump: 3.0.0-dev
