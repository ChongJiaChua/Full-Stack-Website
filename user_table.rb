#encryption/decryption class

class User < Sequel::Model

  def encrypt(params)
    password = params.fetch("newPassword", "").strip
    @data = password
    # Set up AES for encryption.
    aes = OpenSSL::Cipher.new('AES-128-CBC').encrypt

    # Generate a random IV.
    @iv = Sequel.blob(aes.random_iv)

    # Generate a random salt.
    @salt = Sequel.blob(OpenSSL::Random.random_bytes(16))

    # Get the key from the password and salt.
    aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, @salt, 20_000, 16)

    # Encrypt the data
    @data_crypt = Sequel.blob(aes.update(@data) + aes.final)
    true
  end

  def getDataCrypt()
    return @data_crypt
  end
  
  def getSalt()
    return @salt
  end
  def setSalt(salt)
    @salt = salt
  end


  def getIv()
    return @iv
  end
  def setIv(iv)
    @iv = iv
  end

  def setDataCrypt(data)
    @data_crypt = data
  end

  def login(params)
    password = params.fetch("password", "").strip
  
    # Set up AES for decryption.
    aes = OpenSSL::Cipher.new('AES-128-CBC').decrypt

    # Set the IV.
    aes.iv = @iv

    # Get the key from the password and salt.
    aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, @salt, 20_000, 16)

    # Try to decrypt the data.
    begin
      @data_crypt = aes.update(@data_crypt) + aes.final
    rescue OpenSSL::Cipher::CipherError
      nil
    end

    if (@data_crypt.eql?(password) == true) then
      return true
    else
      return false
    end

  end



end