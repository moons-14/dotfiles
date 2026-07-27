# Fingerprint Commands

This note covers the basic `fprintd` commands used by the fingerprint module.

## Enroll a new fingerprint

Register a fingerprint for the current user:

```sh
fprintd-enroll $USER
```

To enroll a specific finger, pass the finger name:

```sh
fprintd-enroll -f right-index-finger $USER
```

Common finger names include:

- `left-thumb`
- `left-index-finger`
- `right-thumb`
- `right-index-finger`

Follow the prompts and swipe or touch the sensor until enrollment completes.

## List enrolled fingerprints

Show fingerprints registered for the current user:

```sh
fprintd-list $USER
```

You can also list fingerprints for another user:

```sh
fprintd-list <username>
```

## Delete fingerprints

Delete one enrolled fingerprint for the current user:

```sh
fprintd-delete
```

Delete all enrolled fingerprints for the current user:

```sh
fprintd-delete $USER
```

Delete fingerprints for another user:

```sh
fprintd-delete <username>
```

## Verify authentication

Test fingerprint authentication for the current user:

```sh
fprintd-verify
```
