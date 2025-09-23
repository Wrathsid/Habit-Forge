"""
Logger setup for the application
"""

import logging
import sys
from config import Config

def setup_logger(name: str) -> logging.Logger:
    """Setup logger with consistent configuration"""
    try:
        logger = logging.getLogger(name)
        
        if not logger.handlers:
            # Create console handler
            handler = logging.StreamHandler(sys.stdout)
            
            # Get log level with fallback
            try:
                log_level = getattr(logging, Config.LOG_LEVEL)
            except AttributeError:
                log_level = logging.INFO  # Default fallback
                # Invalid log level, using INFO as fallback
            
            handler.setLevel(log_level)
            
            # Create formatter
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            
            # Add handler to logger
            logger.addHandler(handler)
            logger.setLevel(log_level)
        
        return logger
    except Exception as e:
        # Fallback logger if setup fails
        # Error setting up logger, using fallback
        fallback_logger = logging.getLogger(name)
        if not fallback_logger.handlers:
            handler = logging.StreamHandler(sys.stdout)
            handler.setLevel(logging.INFO)
            formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
            handler.setFormatter(formatter)
            fallback_logger.addHandler(handler)
            fallback_logger.setLevel(logging.INFO)
        return fallback_logger
