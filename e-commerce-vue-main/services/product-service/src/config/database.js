import mongoose from 'mongoose';
import fs from 'fs';

const readSecret = (secretName) => {
  try {
    return fs.readFileSync(`/run/secrets/${secretName}`, 'utf8').trim();
  } catch (error) {
    console.warn(`⚠️  Secret ${secretName} not found, falling back to env var`);
    return null;
  }
};

export const connectDB = async () => {
  try {
    if (mongoose.connection.readyState !== 0 || process.env.NODE_ENV === 'test') {
      console.log('MongoDB déjà connecté ou en mode test');
      return;
    }

    const mongoUri = readSecret('mongodb_uri_products') || process.env.MONGODB_URI;
    
    if (!mongoUri) {
      throw new Error('❌ MongoDB URI not found in secrets or environment variables');
    }

    const conn = await mongoose.connect(mongoUri);
    
    const safeUri = mongoUri.replace(/\/\/.*@/, '//***:***@');
    console.log(`📦 Product Service - MongoDB Connected: ${conn.connection.host}`);
    console.log(`📊 Using URI: ${safeUri}`);
    
  } catch (error) {
    console.error(`❌ Product Service MongoDB Error: ${error.message}`);
    setTimeout(connectDB, 5000);
  }
};

export const getJWTSecret = () => {
  const jwtSecret = readSecret('jwt_secret') || process.env.JWT_SECRET;
  
  if (!jwtSecret) {
    throw new Error('❌ JWT Secret not found in secrets or environment variables');
  }
  
  return jwtSecret;
};