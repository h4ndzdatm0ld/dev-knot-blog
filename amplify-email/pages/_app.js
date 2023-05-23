import { ChakraProvider } from '@chakra-ui/react'
import Amplify from '@aws-amplify/core'
import config from '../../src/aws-exports'
import theme from '../components/theme';
Amplify.configure(config)


function MyApp({ Component, pageProps }) {
  return (
    <ChakraProvider theme={theme}>
      <Component {...pageProps} />
    </ChakraProvider>
  )
}
export default MyApp
