#include "regex.h"

#include <algorithm>
#include <cstring>
#include <regex>
#include <string>

namespace {
struct regex_state {
    std::regex expression;
};

char *
copy_message(const std::string &message)
{
    char *copy = static_cast<char *>(std::malloc(message.size() + 1));
    if (copy != nullptr)
        std::memcpy(copy, message.c_str(), message.size() + 1);
    return copy;
}
}

extern "C" int
regcomp(regex_t *expression, const char *pattern, int flags)
{
    try {
        std::regex_constants::syntax_option_type options =
            std::regex_constants::extended;
        if (flags & REG_ICASE)
            options |= std::regex_constants::icase;
        if (flags & REG_NOSUB)
            options |= std::regex_constants::nosubs;
        regex_state *state = new regex_state{std::regex(pattern, options)};
        expression->implementation = state;
        expression->re_nsub = state->expression.mark_count();
        expression->error_message = nullptr;
        return 0;
    } catch (const std::regex_error &error) {
        expression->implementation = nullptr;
        expression->re_nsub = 0;
        expression->error_message = copy_message(error.what());
        return REG_BADPAT;
    }
}

extern "C" int
regexec(const regex_t *expression, const char *text, size_t match_count,
    regmatch_t matches[], int flags)
{
    const regex_state *state = static_cast<const regex_state *>(expression->implementation);
    std::cmatch results;
    std::regex_constants::match_flag_type options = std::regex_constants::match_default;
    if (flags & REG_NOTBOL)
        options |= std::regex_constants::match_not_bol;
    if (flags & REG_NOTEOL)
        options |= std::regex_constants::match_not_eol;
    if (!std::regex_search(text, results, state->expression, options))
        return REG_NOMATCH;
    const size_t count = std::min(match_count, results.size());
    for (size_t index = 0; index < count; ++index) {
        if (results[index].matched) {
            matches[index].rm_so = results.position(index);
            matches[index].rm_eo = results.position(index) + results.length(index);
        } else {
            matches[index].rm_so = -1;
            matches[index].rm_eo = -1;
        }
    }
    for (size_t index = count; index < match_count; ++index) {
        matches[index].rm_so = -1;
        matches[index].rm_eo = -1;
    }
    return 0;
}

extern "C" size_t
regerror(int error_code, const regex_t *expression, char *buffer,
    size_t buffer_size)
{
    std::string message;
    if (expression != nullptr && expression->error_message != nullptr)
        message = expression->error_message;
    else if (error_code == REG_NOMATCH)
        message = "no match";
    else
        message = "invalid regular expression";
    const size_t required = message.size() + 1;
    if (buffer != nullptr && buffer_size > 0) {
        const size_t length = std::min(message.size(), buffer_size - 1);
        std::memcpy(buffer, message.data(), length);
        buffer[length] = '\0';
    }
    return required;
}

extern "C" void
regfree(regex_t *expression)
{
    delete static_cast<regex_state *>(expression->implementation);
    std::free(expression->error_message);
    expression->implementation = nullptr;
    expression->error_message = nullptr;
    expression->re_nsub = 0;
}
