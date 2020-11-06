-- This package provides a dictionary types and operations
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2020, Lars Asplund lars.anders.asplund@gmail.com
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;

use work.string_ops.all;
use work.logger_pkg.all;
use std.textio.all;

package dictionary is
  subtype frozen_dictionary_t is string;
  constant empty : frozen_dictionary_t := "";
  -- Deprecated
  constant empty_c : frozen_dictionary_t := empty;

  function len (
    constant d : frozen_dictionary_t)
    return natural;

  impure function get (
    constant d   : frozen_dictionary_t;
    constant key : string)
    return string;

  impure function has_key (
    constant d   : frozen_dictionary_t;
    constant key : string)
    return boolean;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : string)
    return string;

  alias get_string is get[frozen_dictionary_t, string, string return string];

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : character)
    return character;

  alias get_character is get[frozen_dictionary_t, string, character return character];

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : bit)
    return bit;

  alias get_bit is get[frozen_dictionary_t, string, bit return bit];

  impure function get (
      d             : frozen_dictionary_t;
      key           : string;
      default_value : std_ulogic)
      return std_ulogic;

  alias get_std_ulogic is get[frozen_dictionary_t, string, std_ulogic return std_ulogic];

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : bit_vector)
    return bit_vector;

  alias get_bit_vector is get[frozen_dictionary_t, string, bit_vector return bit_vector];

  impure function get (
      d             : frozen_dictionary_t;
      key           : string;
      default_value : std_ulogic_vector)
      return std_ulogic_vector;

  alias get_std_ulogic_vector is get[frozen_dictionary_t, string, std_ulogic_vector return std_ulogic_vector];

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : signed)
    return signed;

  alias get_signed is get[frozen_dictionary_t, string, signed return signed];

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : unsigned)
    return unsigned;

  alias get_unsigned is get[frozen_dictionary_t, string, unsigned return unsigned];

  impure function get (
      d             : frozen_dictionary_t;
      key           : string;
      default_value : real)
      return real;

  alias get_real is get[frozen_dictionary_t, string, real return real];

  impure function get (
      d             : frozen_dictionary_t;
      key           : string;
      default_value : integer)
      return integer;

  alias get_integer is get[frozen_dictionary_t, string, integer return integer];

  impure function get (
      d             : frozen_dictionary_t;
      key           : string;
      default_value : time)
      return time;

  alias get_time is get[frozen_dictionary_t, string, time return time];

  impure function get (
      d             : frozen_dictionary_t;
      key           : string;
      default_value : boolean)
      return boolean;

  alias get_boolean is get[frozen_dictionary_t, string, boolean return boolean];

  constant dictionary_logger : logger_t := get_logger("vunit_lib:dictionary");

end package dictionary;

package body dictionary is
  function len (
    constant d : frozen_dictionary_t)
    return natural is
  begin
    return count(replace(d, "::", "__escaped_colon__"), ":");
  end;

  type dictionary_status_t is (valid_value, key_error, corrupt_dictionary);

  procedure get (
    constant d     : in  frozen_dictionary_t;
    constant key   : in  string;
    variable value : inout line;
    variable status : out dictionary_status_t) is
    variable key_value_pairs, key_value_pair : lines_t;
  begin
    if value /= null then
      deallocate(value);
    end if;

    if len(d) = 0 then
      status := key_error;
      return;
    end if;

    key_value_pairs := split(replace(d, ",,", "__escaped_comma__"), ",");
    for i in key_value_pairs'range loop
      key_value_pair := split(replace(key_value_pairs(i).all, "::", "__escaped_colon__"), ":");
      if key_value_pair'length = 2 then
        if strip(replace(replace(key_value_pair(0).all, "__escaped_comma__", ','), "__escaped_colon__", ':')) = strip(key) then
          status := valid_value;
          write(value, strip(replace(replace(key_value_pair(1).all, "__escaped_comma__", ','), "__escaped_colon__", ':')));
          return;
        end if;
      else
        failure(dictionary_logger, "Corrupt frozen dictionary item """ & key_value_pairs(i).all & """ in """ & d & """.");
        write(value, string'("will return when log is mocked out during unit test."));
        return;
      end if;

    end loop;

    status := key_error;
    return;
  end procedure get;

  impure function get (
    constant d   : frozen_dictionary_t;
    constant key : string)
    return string is
    variable value : line;
    variable status : dictionary_status_t;
  begin
    get(d, key, value, status);
    if status = valid_value then
      return value.all;
    else
      failure(dictionary_logger, "Key error! """ & key & """ wasn't found in """ & d & """.");
      return "will return when log is mocked out during unit test.";
    end if;

  end;

  impure function has_key (
    constant d   : frozen_dictionary_t;
    constant key : string)
    return boolean is
    variable value : line;
    variable status : dictionary_status_t;
  begin
    get(d, key, value, status);
    return status = valid_value;
  end;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : string)
    return string is
  begin
    if (has_key(d, key) = True) then
      return get(d, key);
    else
      return default_value;
    end if;
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : character)
    return character is
  begin
    return character'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : bit)
    return bit is
  begin
    return bit'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : std_ulogic)
    return std_ulogic is
  begin
    return std_ulogic'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : bit_vector)
    return bit_vector is
  begin
    return bit_vector'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : std_ulogic_vector)
    return std_ulogic_vector is
  begin
    return std_ulogic_vector'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : signed)
    return signed is
  begin
    return signed'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : unsigned)
    return unsigned is
  begin
    return unsigned'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : real)
    return real is
  begin
    return real'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : integer)
    return integer is
  begin
    return integer'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : time)
    return time is
  begin
    return time'value(get(d, key, to_string(default_value)));
  end function get;

  impure function get (
    d             : frozen_dictionary_t;
    key           : string;
    default_value : boolean)
    return boolean is
  begin
    return boolean'value(get(d, key, to_string(default_value)));
  end function get;

end package body dictionary;
