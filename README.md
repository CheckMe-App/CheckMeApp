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

- [x ] User can create a daily task
- [ x] User can edit and delete a task
- [ x] User can check off a task for today
- [ x] Tasks reset each new day
- [ x] User can see their history of completed tasks
- [ x] User can see their streak and stats on their profile


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

<img width="360" height="696" alt="CheckMe-demo" src="https://github.com/user-attachments/assets/d7a72a56-981f-490a-8b9b-3ce86ab7281d" />

demo: https://www.youtube.com/watch?v=AdfFJoZRF7Y



