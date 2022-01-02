const { PrismaClient } = require('@prisma/client')
const { ApolloServer, gql } = require('apollo-server');
const { readFileSync } = require('fs')
const path = require('path');

const prisma = new PrismaClient()

const AdminRegion={
  id: (parent) => parent.code.trim(),
  name: (parent) => parent.name,
  country: (parent, args, context, info) => {
    return context.prisma.countryinfo.findUnique({
    where: {
      iso_alpha2: parent.code.substring(0,2)
    }
  })
}
}
const Location = {
  population: (parent) => String(parent.population),
  country:(parent, args, context, info) => {
    return context.prisma.countryinfo.findUnique({
      where: {
        iso_alpha2: parent.country.toUpperCase()
      }
    })
  },
  timezone:(parent, args, context, info) => {
    return context.prisma.timezones.findUnique({
      where: {
        id : parent.timezone
      }
    })
  },
  adminregion:(parent, args, context, info) => {
    return context.prisma.admin1codesascii.findFirst({
      where: {
          code : parent.country.toUpperCase()+'.'+parent.admin1,
      }
    })
  },
  type:async (parent, args, context, info) => {
     const featurecode = await context.prisma.featurecodes.findFirst({
      where: {
          code : parent.fclass+'.'+parent.fcode
      }
    });
    return featurecode.name;
  },
  position:(parent, args, context, info) => {
    return {
      latitude: parent.latitude, 
      longitude: parent.longitude
    }
  }
}
const Continent = {
  id: (parent, args, context, info) => parent.code,
//  name: (parent) => parent.name
}
const Country = {
  // correct ugly uppercase for this key (for unknown reason?)
  id: (parent) => parent.iso_alpha2.toLowerCase(),
  name: (parent) => parent.country,
  continent: (parent, args, context, info) => {
    return context.prisma.continentcodes.findUnique({
      where: {
        code: parent.continent,
      },
    })
  },
  languages: (parent, args, context, info) => {
    if ( parent.languages!== null )
    {
      // regex: list is language,language,language-country,language-country,language 
      // so in some cases language is a two letter code, in some cases two letters, hyphen, two letters
      // this regex includes the optional "-country", as part of the splitter
      const languages=parent.languages.split(/(?:-\w{2})?(?:,|$)/).filter(n => n);
      return context.prisma.iso_languagecodes.findMany({
        where: {
          // not a bug - for some reason geonames uses the iso_639_1 (2 letters) as a key 
          // between countries and langauges, but iso_639_3 (3 letters) as key in languages table
          // we've abstracted the use of two letter language codes away, always going with three letters
          iso_639_1: { in: languages },
        },
      })
    }
  },
//  capital: (parent) => parent.capital,
 // area: (parent) => parent.area,
 // population: (parent) => parent.population
}
const Currency = {
  id: (parent) => parent.currency_code,
  name: (parent) => parent.currency_name,
}
const Language = {
  id: (parent) => parent.iso_639_3.trim().toLowerCase(),
  name: (parent) => parent.language_name,
}
const Point = {
 // latitude: () => 55.0,
 // longitude: () => 55.0
  // latitude
  // longitude
}
const Timezone = {
//  id: (parent) => parent.id,
 // country_code: (parent) => parent.country_code,
 // gmt_offset: (parent) => parent.gmt_offset
}



const resolvers = {
  AdminRegion,
  Continent,
  Country,
  Currency, 
  Language,
  Location,
  Point,
  Timezone,
  Query: {
    adminregion: async(parent, args, context, info) => {
      return await prisma.admin1codesascii.findUnique({
        where: {
          code: args.id,
        },
      })
    },
    adminregions: async(parent, args, context, info) => {
      return await prisma.admin1codesascii.findMany({
        where: {
          code: {
            startsWith: args.country,
          }
        },
      })
    },
    location: async(parent, args, context, info) => {
      return await prisma.geoname.findFirst({
        where: {
          id: parseInt(args.id),
          population: 
          {
            gt: 0,
          }
        }
      })
    },
    findlocations: async(parent, args, context, info) => {
      const offset=0

      return await prisma.geoname.findMany({
          // first  [take in prisma]
          // offset [skip in prismma]
          where: {
          country: args.country.toUpperCase(),
          population: 
          {
            gt: 0,
          },
          name: 
          {
            contains: args.name,
            mode: 'insensitive'
          },
        },
      })
    },
    continents: async() => { 
      return await prisma.continentcodes.findMany();
    },
    continent: async (parent, args, context, info) => {
      return await prisma.continentcodes.findUnique({
        where: {
          code: args.id,
        },
      })
    },
    countries: async() => { 
      return await prisma.countryinfo.findMany({
        where: {}
      })
    },
    country: async(parent, args, context, info) => { 
      return await prisma.countryinfo.findUnique({
        where: {
          iso_alpha2: args.id.toUpperCase()
        }
      })
    },
    currencies: async() => {
      return await prisma.countryinfo.findMany({
        where: {},
        distinct: ['currency_code', 'currency_name'],
      })
    },
    currency: async(parent, args, context, info) => {
      return await prisma.countryinfo.findUnique({
        where: {
          currency_code: args.id,
        },
        distinct: ['currency_code', 'currency_name'],
      })
    },
    languages: async() => {
      return await prisma.iso_languagecodes.findMany({
        where: {},
      })
    },
    language: async(parent, args, context, info) => {
      return await prisma.iso_languagecodes.findUnique({
        where: {
          iso_639_3: args.id,
        },
      })
    },
    timezones: async() => { 
      return await prisma.timezones.findMany();
    },
    timezone: async() => {
      return await prisma.timezones.findUnique({
        where: {
          id: args.id,
        },
      })
    }
  }
};

const server = new ApolloServer({
  typeDefs: readFileSync(
    path.join(__dirname, 'schema.graphql'),
    'utf8'
  ),
  resolvers,
  context: {
    prisma,
  }
})

server.listen().then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});