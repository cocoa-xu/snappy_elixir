#include <erl_nif.h>
#include <cstring>
#include <string>
#include "nif_utils.hpp"
#include "snappy.h"

#ifdef __GNUC__
#  pragma GCC diagnostic ignored "-Wunused-parameter"
#  pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#  pragma GCC diagnostic ignored "-Wunused-variable"
#  pragma GCC diagnostic ignored "-Wunused-function"
#endif

static ERL_NIF_TERM compress_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 1) {
        return erlang::nif::error(env, "expecting 1 argument: data");
    }

    ErlNifBinary data;
    if (enif_inspect_binary(env, argv[0], &data)) {
        char * output = (char *)enif_alloc(snappy::MaxCompressedLength(data.size));
        size_t out_size;
        if (output) {
            const char * error_msg = nullptr;
            ErlNifBinary out_binary;
            snappy::RawCompress((const char *)data.data, data.size, output, &out_size);
            if (enif_alloc_binary(out_size, &out_binary)) {
                memcpy(out_binary.data, output, out_size);
            } else {
                error_msg = "enif_alloc_binary failed";
            }

            enif_free((void *)output);
            if (error_msg) {
                return erlang::nif::error(env, error_msg);
            } else {
                ERL_NIF_TERM bin = enif_make_binary(env, &out_binary);
                return erlang::nif::ok(env, bin);
            }
        } else {
            return erlang::nif::error(env, "enif_alloc failed");
        }
    } else {
        return erlang::nif::error(env, "enif_inspect_binary failed");
    }
}

static ERL_NIF_TERM uncompress_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 1) {
        return erlang::nif::error(env, "expecting 1 argument: compressed");
    }

    ErlNifBinary data;
    if (enif_inspect_binary(env, argv[0], &data)) {
        size_t out_size = 0;
        const char * error_msg = nullptr;
        if (snappy::GetUncompressedLength((const char *)data.data, data.size, &out_size)) {
            char * output = (char *)enif_alloc(out_size);
            if (output) {
                ErlNifBinary out_binary;
                if (snappy::RawUncompress((const char *)data.data, data.size, output)) {
                    if (enif_alloc_binary(out_size, &out_binary)) {
                        memcpy(out_binary.data, output, out_size);
                    } else {
                        error_msg = "enif_alloc_binary failed";
                    }
                } else {
                    error_msg = "snappy::RawUncompress failed";
                }

                enif_free((void *)output);
                if (error_msg) {
                    return erlang::nif::error(env, error_msg);
                } else {
                    ERL_NIF_TERM bin = enif_make_binary(env, &out_binary);
                    return erlang::nif::ok(env, bin);
                }
            } else {
                return erlang::nif::error(env, "enif_alloc failed");
            }
        } else {
            return erlang::nif::error(env, "snappy::GetUncompressedLength failed");
        }
    } else {
        return erlang::nif::error(env, "enif_inspect_binary failed");
    }
}

static ERL_NIF_TERM max_compressed_length_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 1) {
        return erlang::nif::error(env, "expecting 1 argument: data");
    }

    ErlNifBinary data;
    if (enif_inspect_binary(env, argv[0], &data)) {
        size_t max_size = snappy::MaxCompressedLength(data.size);
        return erlang::nif::ok(env, enif_make_uint64(env, max_size));
    } else {
        return erlang::nif::error(env, "enif_inspect_binary failed");
    }
}

static ERL_NIF_TERM uncompressed_length_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 1) {
        return erlang::nif::error(env, "expecting 1 argument: compressed");
    }

    ErlNifBinary data;
    if (enif_inspect_binary(env, argv[0], &data)) {
        size_t out_size = 0;
        if (snappy::GetUncompressedLength((const char *)data.data, data.size, &out_size)) {
            return erlang::nif::ok(env, enif_make_uint64(env, out_size));
        } else {
            return erlang::nif::error(env, "snappy::GetUncompressedLength failed");
        }
    } else {
        return erlang::nif::error(env, "enif_inspect_binary failed");
    }
}

static ERL_NIF_TERM is_valid_compressed_buffer_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 2) {
        return erlang::nif::error(env, "expecting 2 arguments: compressed, size");
    }

    ErlNifBinary data;
    ErlNifUInt64 size;
    if (enif_inspect_binary(env, argv[0], &data) && enif_get_uint64(env, argv[1], &size)) {
        if (size <= data.size && snappy::IsValidCompressedBuffer((const char *)data.data, (size_t)size)) {
            return enif_make_atom(env, "true");
        } else {
            return enif_make_atom(env, "false");
        }
    } else {
        return enif_make_atom(env, "false");
    }
}

static int on_load(ErlNifEnv* env, void**, ERL_NIF_TERM)
{
    return 0;
}

static int on_reload(ErlNifEnv*, void**, ERL_NIF_TERM)
{
    return 0;
}

static int on_upgrade(ErlNifEnv*, void**, void**, ERL_NIF_TERM)
{
    return 0;
}

static ErlNifFunc nif_functions[] = {
    {"compress", 1, compress_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"uncompress", 1, uncompress_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"max_compressed_length", 1, max_compressed_length_nif, 0},
    {"uncompressed_length", 1, uncompressed_length_nif, 0},
    {"is_valid_compressed_buffer", 2, is_valid_compressed_buffer_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},
};

ERL_NIF_INIT(Elixir.Snappy.Nif, nif_functions, on_load, on_reload, on_upgrade, NULL);

#if defined(__GNUC__)
#pragma GCC visibility push(default)
#endif
