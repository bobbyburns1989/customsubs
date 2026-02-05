# Architecture Documentation

**Technical architecture and design documentation** for CustomSubs.

---

## 📁 What's Here

Deep-dive technical documentation explaining how CustomSubs is structured and why specific architectural decisions were made.

### Architecture Docs

| Document | Topic | Key Concepts |
|----------|-------|--------------|
| [overview.md](overview.md) | System architecture | Feature-first, clean architecture, offline-first |
| [state-management.md](state-management.md) | Riverpod patterns | AsyncNotifier, code generation, providers |
| [data-layer.md](data-layer.md) | Data persistence | Hive, repositories, models, TypeAdapters |
| [design-system.md](design-system.md) | UI design | Colors, typography, spacing, components |

---

## 🎯 When to Use These Docs

- **New to the codebase?** Start with [overview.md](overview.md)
- **Adding state management?** Read [state-management.md](state-management.md)
- **Working with data?** See [data-layer.md](data-layer.md)
- **Styling UI?** Reference [design-system.md](design-system.md)

---

## 🏗️ Core Architecture Principles

1. **Privacy First** - No network calls, 100% offline
2. **Offline First** - Works without internet connection
3. **Separation of Concerns** - Clear layer boundaries
4. **Feature-First Structure** - Self-contained feature modules
5. **Repository Pattern** - Centralized data access

---

## 🔗 Quick Links

- [📋 Back to Documentation Index](../INDEX.md)
- [📘 Implementation Guides](../guides/)
- [📐 Architectural Decision Records](../decisions/)
- [📝 CLAUDE.md](../../CLAUDE.md) - Complete project spec

---

**Last Updated**: February 4, 2026
**Architecture Style**: Clean Architecture + Feature-First
**Stack**: Flutter + Riverpod + Hive + GoRouter
