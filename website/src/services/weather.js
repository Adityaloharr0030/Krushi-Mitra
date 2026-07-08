// 🌦️ Krushi Mitra Pro Weather Service

export async function getWeather(lat, lon, cityName = 'Pune', apiKey = '') {
  if (apiKey && apiKey.length > 5) {
    try {
      const weatherUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;
      const res = await fetch(weatherUrl);
      if (!res.ok) throw new Error(`Weather fetch failed: ${res.status}`);
      const data = await res.json();
      
      const forecastUrl = `https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;
      const forecastRes = await fetch(forecastUrl);
      let forecasts = [];
      if (forecastRes.ok) {
        const forecastData = await forecastRes.json();
        forecasts = parseForecastData(forecastData.list);
      } else {
        forecasts = generateMockForecasts(data.main.temp);
      }

      return formatWeatherData(data, forecasts);
    } catch (e) {
      console.warn("API Weather error, returning fallback simulation:", e);
      return getSimulatedWeather(cityName);
    }
  } else {
    return getSimulatedWeather(cityName);
  }
}

function parseForecastData(list) {
  // Extract daily forecasts (1 entry per day, e.g. at 12:00 PM)
  const daily = [];
  const datesSeen = new Set();
  
  for (const item of list) {
    const dateStr = item.dt_txt.split(' ')[0];
    const timeStr = item.dt_txt.split(' ')[1];
    
    if (!datesSeen.has(dateStr) && timeStr === '12:00:00') {
      datesSeen.add(dateStr);
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const date = new Date(item.dt * 1000);
      
      daily.push({
        day: days[date.getDay()],
        temp: Math.round(item.main.temp),
        condition: item.weather[0].main,
        icon: item.weather[0].icon,
        humidity: item.main.humidity,
        wind: Math.round(item.wind.speed * 3.6), // m/s to km/h
      });
    }
  }
  return daily;
}

function generateMockForecasts(currentTemp) {
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const todayIndex = new Date().getDay();
  const conditions = ['Clear', 'Clouds', 'Rain', 'Clouds', 'Clear', 'Rain', 'Clouds'];
  
  return Array.from({ length: 7 }, (_, i) => {
    const dayName = days[(todayIndex + i) % 7];
    const offset = Math.floor(Math.random() * 5) - 2;
    const cond = conditions[(todayIndex + i) % conditions.length];
    
    return {
      day: dayName,
      temp: Math.round(currentTemp + offset),
      condition: cond,
      humidity: Math.floor(Math.random() * 20) + 60,
      wind: Math.floor(Math.random() * 15) + 5
    };
  });
}

function formatWeatherData(apiData, forecasts) {
  const temp = Math.round(apiData.main.temp);
  const condition = apiData.weather[0].main;
  const humidity = apiData.main.humidity;
  
  return {
    temperature: temp,
    feelsLike: Math.round(apiData.main.feels_like),
    condition: condition,
    description: apiData.weather[0].description,
    humidity: humidity,
    windSpeed: Math.round(apiData.wind.speed * 3.6),
    rainChance: condition.toLowerCase().includes('rain') ? 85 : 15,
    cityName: apiData.name,
    uvIndex: 7,
    dailyForecasts: forecasts,
    advisory: getWeatherAdvisory(condition, temp, humidity)
  };
}

function getWeatherAdvisory(condition, temp, humidity) {
  const cond = condition.toLowerCase();
  if (cond.includes('rain') || cond.includes('thunder') || cond.includes('drizzle')) {
    return {
      title: "🌧️ Heavy Rain Alert",
      text: "Avoid chemical spraying and pesticide applications today as it will wash away. Keep harvested crops in dry storage immediately. Clear drainage channels.",
      safeToSpray: false,
      safeToHarvest: false
    };
  }
  if (temp > 38) {
    return {
      title: "☀️ High Temperature Warning",
      text: "Extreme heat detected. Irrigate crops during early morning (before 7 AM) or late evening to prevent evaporation. Avoid applying urea during mid-day.",
      safeToSpray: true,
      safeToHarvest: true
    };
  }
  if (humidity > 80) {
    return {
      title: "🌾 High Humidity advisory",
      text: "Humidity is high, which promotes fungal growth (Blights/Mildew). Monitor vegetable crops closely and apply neem oil preventatively if needed.",
      safeToSpray: true,
      safeToHarvest: true
    };
  }
  return {
    title: "🟢 Perfect Weather Conditions",
    text: "Optimal weather for crop management. Sowing, fertilizer application, and chemical spraying are highly safe. Perfect timing for harvesting mature crops.",
    safeToSpray: true,
    safeToHarvest: true
  };
}

export function getSimulatedWeather(cityName = 'Pune') {
  const normalizedCity = cityName.toLowerCase();
  
  // Dynamic defaults based on common locations
  let baseTemp = 28;
  let condition = 'Clear';
  let humidity = 55;
  let windSpeed = 12;

  const today = new Date();
  const month = today.getMonth() + 1; // 1-12

  // Simulate seasonal monsoon in India (June-Sept)
  if (month >= 6 && month <= 9) {
    condition = 'Rain';
    humidity = 88;
    baseTemp = 26;
    windSpeed = 22;
  } else if (month >= 10 && month <= 2) {
    // Winter (Oct-Feb)
    condition = 'Clear';
    humidity = 45;
    baseTemp = 22;
    windSpeed = 8;
  } else {
    // Summer (March-May)
    condition = 'Clouds';
    humidity = 40;
    baseTemp = 36;
    windSpeed = 16;
  }

  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const todayIndex = today.getDay();
  const forecastConditions = {
    Rain: ['Rain', 'Rain', 'Clouds', 'Rain', 'Clouds', 'Rain', 'Rain'],
    Clear: ['Clear', 'Clear', 'Clouds', 'Clear', 'Clear', 'Clouds', 'Clear'],
    Clouds: ['Clouds', 'Clear', 'Clouds', 'Clouds', 'Clear', 'Clouds', 'Clouds']
  };

  const dailyForecasts = Array.from({ length: 7 }, (_, i) => {
    const dayName = days[(todayIndex + i) % 7];
    const offset = Math.floor(Math.random() * 4) - 2;
    const cond = forecastConditions[condition][(todayIndex + i) % 7];
    
    return {
      day: dayName,
      temp: baseTemp + offset,
      condition: cond,
      humidity: condition === 'Rain' ? Math.floor(Math.random() * 15) + 75 : Math.floor(Math.random() * 20) + 40,
      wind: windSpeed + Math.floor(Math.random() * 6) - 3
    };
  });

  return {
    temperature: baseTemp,
    feelsLike: baseTemp + 2,
    condition: condition,
    description: condition === 'Rain' ? 'moderate monsoon showers' : condition === 'Clear' ? 'clear sunny sky' : 'broken clouds',
    humidity: humidity,
    windSpeed: windSpeed,
    rainChance: condition === 'Rain' ? 90 : 10,
    cityName: cityName,
    uvIndex: condition === 'Clear' ? 9 : 4,
    dailyForecasts: dailyForecasts,
    advisory: getWeatherAdvisory(condition, baseTemp, humidity)
  };
}
