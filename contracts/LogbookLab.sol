// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogbookLab {
    struct Peminjaman {
        string namaAlat;
        bool sudahDikembalikan;
        uint256 waktuPinjam;
        address peminjam;
    }

    Peminjaman[] private daftarPinjaman;

    event PinjamBaru(uint256 id, string namaAlat, address peminjam);
    event AlatDikembalikan(uint256 id);

    function pinjamAlat(string calldata _namaAlat) external {
        require(bytes(_namaAlat).length > 0, "Nama alat tidak boleh kosong");
        daftarPinjaman.push(Peminjaman(_namaAlat, false, block.timestamp, msg.sender));
        emit PinjamBaru(daftarPinjaman.length - 1, _namaAlat, msg.sender);
    }

    function kembalikanAlat(uint256 _id) external {
        require(_id < daftarPinjaman.length, "Data peminjaman tidak ada");
        require(daftarPinjaman[_id].peminjam == msg.sender, "Hanya peminjam yang bisa mengembalikan");
        require(!daftarPinjaman[_id].sudahDikembalikan, "Alat sudah dikembalikan sebelumnya");

        daftarPinjaman[_id].sudahDikembalikan = true;
        emit AlatDikembalikan(_id);
    }

    function jumlahPinjaman() external view returns (uint256) {
        return daftarPinjaman.length;
    }

    function ambilPinjaman(uint256 _id) external view returns (string memory, bool, uint256, address) {
        Peminjaman memory p = daftarPinjaman[_id];
        return (p.namaAlat, p.sudahDikembalikan, p.waktuPinjam, p.peminjam);
    }
}