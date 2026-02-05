# Implementation Guides

**Step-by-step guides for implementing features** following CustomSubs patterns.

---

## 📁 What's Here

Practical, actionable guides for common development tasks. Each guide includes code examples, best practices, and common pitfalls to avoid.

### Available Guides

| Guide | Topic | Priority |
|-------|-------|----------|
| [adding-a-feature.md](adding-a-feature.md) | Feature implementation | 🔴 Start here |
| [working-with-notifications.md](working-with-notifications.md) | Notification system | ⚠️ **CRITICAL** |
| [forms-and-validation.md](forms-and-validation.md) | Form patterns | 🟡 Medium |
| [multi-currency.md](multi-currency.md) | Currency handling | 🟡 Medium |

---

## 🚀 Quick Start for New Features

**Adding a new feature to CustomSubs?**

1. Read [adding-a-feature.md](adding-a-feature.md) first (20 min)
2. Follow the step-by-step checklist
3. Reference architecture docs as needed
4. Use templates from [docs/templates/](../templates/)

---

## ⚠️ Critical System: Notifications

Notifications are the **#1 feature** of CustomSubs. If you're working with notifications:

1. **MUST READ**: [working-with-notifications.md](working-with-notifications.md)
2. Never skip notification testing on real devices
3. Use deterministic IDs (see ADR 002)
4. Always use `tz.TZDateTime` with `tz.local`

---

## 🔗 Quick Links

- [📋 Back to Documentation Index](../INDEX.md)
- [🏗️ Architecture Documentation](../architecture/)
- [📐 Architectural Decisions](../decisions/)
- [📄 Feature Template](../templates/feature-template.md)

---

**Last Updated**: February 4, 2026
**Guide Count**: 4 comprehensive guides
**Target Audience**: Developers implementing new features
