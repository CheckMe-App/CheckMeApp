# CheckMe

## Table of Contents

1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Wireframes](#wireframes)
4. [Schema](#schema)
5. [Video Walkthrough](#video-walkthrough)

## Overview

### Description

CheckMe helps users build healthy daily habits. Users create simple daily tasks, like making their bed or eating a healthy breakfast, and check them off each day. Photo proof and streaks keep them accountable.

### App Evaluation

- **Category:** Lifestyle / Social Networking
- **Mobile:** Users log tasks the moment they finish them, using the camera for photo proof and GPS for location check-ins.
- **Story:** Helps users become more productive, accountable and self-aware, so they can become the best version of themselves.
- **Market:** Anyone who wants to improve their daily habits.
- **Habit:** Used every day, until the user can keep their habits without the app.
- **Scope:** V1: create and check off daily tasks. V2: photo proof, location check-ins and congratulations. V3: friends and communities.

## Product Spec

### 1. User Stories

**Required**

- [ ] User can create a daily task
- [ ] User can edit and delete a task
- [ ] User can check off a task for today
- [ ] Tasks reset each new day
- [ ] User can see their history of completed tasks
- [ ] User can see their streak and stats on their profile
- [ ] User can add photo proof when completing a task

**Optional**

- [ ] User gets a congratulations message when finishing all tasks or hitting a streak milestone
- [ ] User can write a diary entry for each day
- [ ] User can attach their location when completing a task
- [ ] User can share progress with friends

### 2. Screen Archetypes

- **Today (Checklist):** see today's tasks, check them off, see progress
- **Add / Edit Task:** create or change a task
- **History (Completed Checklist):** see past days and what was done
- **Profile:** name, streak and stats

### 3. Navigation

**Tab Navigation**

- Today
- History
- Profile

**Flow Navigation**

- Today → Add / Edit Task (sheet)

## Wireframes

<!-- Add a photo of your wireframes here -->

## Schema

### Models

**TaskItem**

| Property | Type | Description |
|---|---|---|
| id | UUID | Unique id |
| title | String | Name of the task |
| createdAt | Date | When the task was created |
| isActive | Bool | Whether the task shows on the checklist |
| completions | [TaskCompletion] | Every day the task was done |

**TaskCompletion**

| Property | Type | Description |
|---|---|---|
| id | UUID | Unique id |
| date | Date | The day this counts for |
| completedAt | Date | Exact time it was checked off |
| photoData | Data? | Optional photo proof |
| task | TaskItem? | The task that was completed |

Data is stored on the device with SwiftData.

## Video Walkthrough

![first demo](https://github.com/user-attachments/assets/6687699d-3b4c-4a33-8ead-0f26f8f0a5df)

