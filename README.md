# MangaRock

Assignment test for NAB Studio recruiting purposes

## Accomplished

- show all mangas and manga information without network connecting
- sync changes from server using update time
- build a flexible design, easy to switch to real backend if it were selected

## How

* using local data store
* sync data logic between server and client:
  - client get lastestUpdateTime from local data store and send to server to check whether there is any changes.
  - If it has any changes, client makes an api call to get listServerID and updateTime for every mangas, then compare with local data store to delete every objects which were not in server response and find all objects need to be update. Finally, client makes a next api call to get manga detail.

## Detail design

* ViewController using manager to make data request and using delegate to listen to manager's events.
* Every manager using some apis or servers to do a specific purpose.
* MangaManager using 2 apis to make local database request and server api request.
* About local coredata:
  - there are 2 viewContext: mainContext for retrieve data and privateContext for update changes from server
  - mainContext listen to privateContext changes to merge changes
  - update all the changes from background

### The sql and coredata files were modified to add update time field.

## Limitation
- There is a memory issue if we have a lot of mangas.
- Every time the characters of a manga has any changes, the manga's update time has to be changes also for checking hasChanges.
