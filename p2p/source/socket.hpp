/* Orchid - WebRTC P2P VPN Market (on Ethereum)
 * Copyright (C) 2017-2019  The Orchid Authors
*/

/* GNU Affero General Public License, Version 3 {{{ */
/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.

 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */


#ifndef ORCHID_SOCKET_HPP
#define ORCHID_SOCKET_HPP

#include <iostream>
#include <string>

#include <boost/endian/conversion.hpp>

#include <asio.hpp>

namespace orc {

class Host {
  private:
    asio::ip::address host_;

  public:
    Host(asio::ip::address host) :
        host_(std::move(host))
    {
    }

    Host(const std::string &host) :
        host_(asio::ip::make_address(host))
    {
    }

    Host(uint32_t host) :
        host_(asio::ip::address_v4(host))
    {
    }

    Host() :
        Host(0)
    {
    }

    operator const asio::ip::address &() const {
        return host_;
    }

    operator in_addr() const {
        in_addr address;
        address.s_addr = boost::endian::native_to_big(host_.to_v4().to_uint());
        return address;
    }
};

class Socket {
  private:
    Host host_;
    uint16_t port_;

    std::tuple<const asio::ip::address &, uint16_t> Tuple() const {
        return std::tie(host_, port_);
    }

  public:
    Socket() :
        port_(0)
    {
    }

    Socket(Host host, uint16_t port) :
        host_(std::move(host)),
        port_(port)
    {
    }

    Socket(asio::ip::address host, uint16_t port) :
        host_(std::move(host)),
        port_(port)
    {
    }

    template <typename Protocol_>
    Socket(const asio::ip::basic_endpoint<Protocol_> &endpoint) :
        host_(endpoint.address()),
        port_(endpoint.port())
    {
    }

    Socket(const Socket &rhs) = default;

    Socket(Socket &&rhs) noexcept :
        host_(std::move(rhs.host_)),
        port_(rhs.port_)
    {
    }

    Socket &operator =(const Socket &rhs) = default;

    Socket &operator =(Socket &&rhs) noexcept {
        host_ = std::move(rhs.host_);
        port_ = rhs.port_;
        return *this;
    }

    const asio::ip::address &Host() const {
        return host_;
    }

    uint16_t Port() const {
        return port_;
    }

    bool operator <(const Socket &rhs) const {
        return Tuple() < rhs.Tuple();
    }

    bool operator ==(const Socket &rhs) const {
        return Tuple() == rhs.Tuple();
    }

    bool operator !=(const Socket &rhs) const {
        return Tuple() != rhs.Tuple();
    }
};

inline std::ostream &operator <<(std::ostream &out, const Socket &socket) {
    return out << socket.Host() << ":" << std::dec << socket.Port();
}

class Four {
  private:
    Socket source_;
    Socket destination_;

    std::tuple<const Socket &, const Socket &> Tuple() const {
        return std::tie(source_, destination_);
    }

  public:
    Four(Socket source, Socket destination) :
        source_(std::move(source)),
        destination_(std::move(destination))
    {
    }

    Four(const Four &rhs) = default;

    Four(Four &&rhs) noexcept :
        source_(std::move(rhs.source_)),
        destination_(std::move(rhs.destination_))
    {
    }

    const Socket &Source() const {
        return source_;
    }

    const Socket &Target() const {
        return destination_;
    }

    bool operator <(const Four &rhs) const {
        return Tuple() < rhs.Tuple();
    }

    bool operator ==(const Four &rhs) const {
        return Tuple() == rhs.Tuple();
    }

    bool operator !=(const Four &rhs) const {
        return Tuple() != rhs.Tuple();
    }
};

inline std::ostream &operator <<(std::ostream &out, const Four &four) {
    return out << "[" << four.Source() << "|" << four.Target() << "]";
}

class Five final :
    public Four
{
  private:
    uint8_t protocol_;

    std::tuple<uint8_t, const Socket &, const Socket &> Tuple() const {
        return std::tie(protocol_, Source(), Target());
    }

  public:
    Five(uint8_t protocol, Socket source, Socket destination) :
        Four(std::move(source), std::move(destination)),
        protocol_(protocol)
    {
    }

    Five(const Five &rhs) = default;

    Five(Five &&rhs) noexcept :
        Four(std::move(rhs)),
        protocol_(rhs.protocol_)
    {
    }

    uint8_t Protocol() const {
        return protocol_;
    }

    bool operator <(const Five &rhs) const {
        return Tuple() < rhs.Tuple();
    }

    bool operator ==(const Five &rhs) const {
        return Tuple() == rhs.Tuple();
    }

    bool operator !=(const Five &rhs) const {
        return Tuple() != rhs.Tuple();
    }
};

inline std::ostream &operator <<(std::ostream &out, const Five &five) {
    return out << "[" << five.Protocol() << "|" << five.Source() << "|" << five.Target() << "]";
}

class Three final :
    public Socket
{
  private:
    uint8_t protocol_;

    std::tuple<uint8_t, const Socket &> Tuple() const {
        return std::tie(protocol_, *this);
    }

  public:
    template <typename... Args_>
    Three(uint8_t protocol, Args_ &&...args) :
        Socket(std::forward<Args_>(args)...),
        protocol_(protocol)
    {
    }

    Three(const Three &rhs) = default;

    Three(Three &&rhs) noexcept :
        Socket(std::move(rhs)),
        protocol_(rhs.protocol_)
    {
    }

    uint8_t Protocol() const {
        return protocol_;
    }

    bool operator <(const Three &rhs) const {
        return Tuple() < rhs.Tuple();
    }

    bool operator ==(const Three &rhs) const {
        return Tuple() == rhs.Tuple();
    }

    bool operator !=(const Three &rhs) const {
        return Tuple() != rhs.Tuple();
    }

    Socket Two() const {
        return static_cast<const Socket &>(*this);
    }
};

inline std::ostream &operator <<(std::ostream &out, const Three &three) {
    return out << "[" << three.Protocol() << "|" << static_cast<const Socket &>(three) << "]";
}

}

#endif//ORCHID_SOCKET_HPP
