import { Heading, Text, List, ListItem } from '@chakra-ui/react'

export const AppHeader = () => {
  return (
    <>
      <Heading
        fontWeight={600}
        fontSize={{ base: '2xl', sm: '4xl', md: '6xl' }}
        lineHeight={'110%'}
      >
        Thank you for your interest. <br /> <br />
        <Text as={'span'} color={'blue.400'}>
          Are you ready to get started?
        </Text>
      </Heading>
      <Text color={'gray.500'}>
        Dev-Knot can help you with your next project. Let us start a conversation and figure out how we can help you.
      </Text>
      <ServicesList />
    </>
  )
}

const ServicesList = () => {
  return (
    <List spacing={3} marginTop={5} styleType="none">
      <ListItem>Custom Nautobot plugin (application) or Jobs development</ListItem>
      <ListItem>Network and Cloud Infrastructure Automation</ListItem>
      <ListItem>Ansible, Nornir or general Python automation workflows</ListItem>
    </List>
  )
}
