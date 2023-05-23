import { Box, Container, Stack } from '@chakra-ui/react'
import { ContactModal } from '../components/ContactModal'
import { AppHeader } from '../components/AppHeader'

export default function HomePage() {
  return (
    <>
      <AppContainer>
        <AppHeader />
        <ContactModal />
      </AppContainer>
    </>
  )
}

const AppContainer = ({ children }) => {
  return (
    <Container maxW={'3xl'}>
      <Stack
        as={Box}
        textAlign={'center'}
        spacing={{ base: 8, md: 14 }}
        py={{ base: 20, md: 36 }}
      >
        {children}
      </Stack>
    </Container>
  )
}
