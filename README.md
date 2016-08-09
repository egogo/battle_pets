# Requirements:
- Redis

# Running
bundle exec foreman start

# Interacting

## Pet service:

Exposes endpoints for creating and retrieving existing pets.

### Public API:

#### List all pets:
```curl -X GET http://localhost:4000/api/v1/pets.json```

#### Get a pet by ID:
```curl -X GET http://localhost:4000/api/v1/pets/:id.json```

#### Get yourself a new pet with random characteristics:
```curl -X POST http://localhost:4000/api/v1/pets.json```

## Arena service:

Exposes endpoints for creating contests and tracking progress of existing ones.
Available contest types: strength, wit, agility, senses.
Created contest gets queued for processing by Contest Worker.

### Public API:

#### List contests:
##### All:
```curl -X GET http://localhost:5000/api/v1/contests.json```
##### Filtered by contestant:
```curl -X GET http://localhost:5000/api/v1/contests.json?contestant_id=2```

#### Get a contest by ID:
```curl -X GET http://localhost:5000/api/v1/contests/:id.json```

#### Create a contest for given two pets and contest type:
```curl -X POST -d "title=Strength%20contest" -d "type=strength" -d "pet_one_id=1" -d "pet_two_id=2" http://localhost:5000/api/v1/contests.json ```


## Contest worker:

Picks a contest from the queue, evaluates it using rules for a given contest type and updates contest and contestants with results.
All contest types will use matching property as the main criteria for evaluation and pet's experience as secondary.

As a result of contest evaluation - worker will update pets and contest using appropriate REST service wrappers.


# Testing
bundle exec rake test
