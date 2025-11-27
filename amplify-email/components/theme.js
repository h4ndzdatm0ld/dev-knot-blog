// theme.js

import { extendTheme } from '@chakra-ui/react';

const theme = extendTheme({
  styles: {
    global: {
      body: {
        bg: 'black',
        color: 'white', // If you want the text to be white
      },
    },
  },
});

export default theme;
