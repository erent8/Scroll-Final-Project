# Sağlık Kayıt Yönetimi Dapp'i
--------------------------------


# 1. Dapp Konsepti:

### Problem:
Geleneksel sağlık kayıt sistemleri genellikle merkezi, güvenliği zayıf ve hastalar için erişimi zor olabilir. Ayrıca, farklı sağlık kuruluşları arasında veri paylaşımı 
da sorunludur.

<br>

### Çözüm:
Blockchain tabanlı bir sağlık kayıt yönetimi Dapp'i, hastaların sağlık verilerini güvenli, şeffaf ve erişilebilir bir şekilde yönetmelerine olanak tanır.
Temel Özellikler:

* Hasta kaydı ve kimlik doğrulama
* Sağlık kayıtlarının güvenli depolanması ve erişimi
* Doktor ve hastane yetkilendirme sistemi
* Hastalar için veri paylaşım kontrolü
* Sağlık kuruluşları arası güvenli veri paylaşımı

# 2. Solidity Sözleşmesi:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthRecordManagement {
    struct Patient {
        address patientAddress;
        string name;
        uint256 dateOfBirth;
        bool exists;
    }

    struct HealthRecord {
        uint256 recordId;
        string recordHash;
        address doctor;
        uint256 timestamp;
    }

    mapping(address => Patient) public patients;
    mapping(address => bool) public doctors;
    mapping(address => mapping(uint256 => HealthRecord)) public patientRecords;
    mapping(address => uint256) public recordCount;

    event PatientRegistered(address patientAddress, string name);
    event DoctorRegistered(address doctorAddress);
    event HealthRecordAdded(address patientAddress, uint256 recordId);

    modifier onlyPatient() {
        require(patients[msg.sender].exists, "Only registered patients can perform this action");
        _;
    }

    modifier onlyDoctor() {
        require(doctors[msg.sender], "Only registered doctors can perform this action");
        _;
    }

    function registerPatient(string memory _name, uint256 _dateOfBirth) public {
        require(!patients[msg.sender].exists, "Patient already registered");
        patients[msg.sender] = Patient(msg.sender, _name, _dateOfBirth, true);
        emit PatientRegistered(msg.sender, _name);
    }

    function registerDoctor() public {
        require(!doctors[msg.sender], "Doctor already registered");
        doctors[msg.sender] = true;
        emit DoctorRegistered(msg.sender);
    }

    function addHealthRecord(address _patientAddress, string memory _recordHash) public onlyDoctor {
        require(patients[_patientAddress].exists, "Patient does not exist");
        uint256 newRecordId = recordCount[_patientAddress]++;
        patientRecords[_patientAddress][newRecordId] = HealthRecord(newRecordId, _recordHash, msg.sender, block.timestamp);
        emit HealthRecordAdded(_patientAddress, newRecordId);
    }

    function getHealthRecord(uint256 _recordId) public view onlyPatient returns (string memory, address, uint256) {
        HealthRecord memory record = patientRecords[msg.sender][_recordId];
        require(bytes(record.recordHash).length > 0, "Record does not exist");
        return (record.recordHash, record.doctor, record.timestamp);
    }

    function getPatientInfo() public view onlyPatient returns (string memory, uint256) {
        Patient memory patient = patients[msg.sender];
        return (patient.name, patient.dateOfBirth);
    }
}
```
Bu sözleşme, hastaların kaydını, doktorların yetkilendirilmesini ve sağlık kayıtlarının güvenli bir şekilde eklenmesini ve erişilmesini sağlar.

# 3. Scroll Sepolia Dağıtımı:

Remix IDE veya Truffle gibi bir geliştirme ortamı kullanarak sözleşmeyi derleyin.
Scroll Sepolia ağına bağlı bir cüzdan (örneğin, MetaMask) kullanarak sözleşmeyi dağıtın.
Dağıtım sonrası, sözleşme adresini not edin ve Scroll Sepolia blok gezgininde doğrulayın.
Temel işlevleri test edin: hasta kaydı, doktor kaydı, sağlık kaydı ekleme ve görüntüleme.

4. GitHub Deposu:

1. Yeni bir GitHub deposu oluşturun: `"Scroll-Medical-Data-dApps"`
2. Solidity sözleşme kodunu contracts klasörüne ekleyin.
3. Bir `README.md` dosyası oluşturun ve aşağıdaki bilgileri içerecek şekilde düzenleyin:

`Scroll-Medical-Data-dApps` ---> - [Sağlık Kayıt Yönetimi DAPP](https://github.com/erent8/Scroll-Medical-Data-dApps/tree/main) 

İçerik: 
- Kullanım Amacı
- Ethereum  Blockchain Kullanımı
- Avantaj ve Dezavantajları
- Neden Kullanılır?

----------------------------------------

Bu Dapp, hastaların sağlık kayıtlarını blockchain üzerinde güvenli bir şekilde yönetmelerini sağlar.

## Sözleşme Fonksiyonları

1. `registerPatient(string memory _name, uint256 _dateOfBirth)`: Yeni bir hasta kaydeder.
2. `registerDoctor()`: Yeni bir doktor kaydeder.
3. `addHealthRecord(address _patientAddress, string memory _recordHash)`: Bir hastanın sağlık kaydını ekler.
4. `getHealthRecord(uint256 _recordId)`: Belirli bir sağlık kaydını görüntüler.
5. `getPatientInfo()`: Hasta bilgilerini görüntüler.

## Veri Yapıları

1. `Patient`: Hasta bilgilerini içerir (adres, isim, doğum tarihi).
2. `HealthRecord`: Sağlık kaydı bilgilerini içerir (kayıt ID, kayıt hash'i, doktor adresi, zaman damgası).

## Nasıl Çalışır

1. Hastalar kendilerini kaydeder ve bir hesap oluştururlar.
2. Doktorlar kendilerini kaydederler ve yetkilendirilirler.
3. Doktorlar, hastaların sağlık kayıtlarını ekleyebilir.
4. Hastalar kendi sağlık kayıtlarına erişebilir ve yönetebilirler.

## Güvenlik ve Gizlilik

- Hasta verileri, IPFS gibi merkezi olmayan bir depolama sisteminde şifrelenmiş olarak saklanır.
- Blockchain'de sadece veri hash'leri depolanır, böylece gizlilik korunur.
- Akıllı sözleşme, sadece yetkili kişilerin belirli işlemleri gerçekleştirmesine izin verir.

## Gelecek Geliştirmeler

- Hasta veri paylaşım izinlerinin yönetimi
- Sağlık kuruluşları arası veri paylaşım protokolü
- Hasta onayı ile araştırma amaçlı anonim veri paylaşımı


Bu projem, Scroll blockchain üzerinde çalışan bir sağlık kayıt yönetimi Dapp'i oluşturmanıza olanak tanır. Hastaların gizliliğini korurken, sağlık verilerinin güvenli bir şekilde yönetilmesini ve paylaşılmasını sağlar. Proje, verilen tüm gereksinimleri karşılamakta ve blockchain teknolojisinin sağlık sektöründeki potansiyel uygulamalarını göstermektedir.
