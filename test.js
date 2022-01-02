const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function main() {
var data = "en,nl,en-uk,fr-fr,nl-be,de,fr,it-it"
console.log()

const result=await prisma.iso_languagecodes.findMany({
    where: {
      iso_639_1: { in: data.split(/(?:-\w{2})?(?:,|$)/) },
    }})

    console.log(result);
}

    main()
  .catch((e) => {
    throw e
  })
  .finally(async () => {
    await prisma.$disconnect()
  })