import { microblog } from "../../declarations/microblog";
import React, { useState } from 'react';
import ReactDOM from 'react-dom';
import { Layout, Menu, PageHeader } from 'antd';
import MyPost from "./mypost";
import MyFollow from "./myfollow";
import TimeLine from "./timeline";
import "antd/dist/antd.css";
import "./index.css";

const { Sider, Content } = Layout;

const App = (props) => {
  const [currentMenu, setCurrentMenu] = useState('post');

  let onMenuSwitched = (e) => {
    console.log('onMenuSwitched to ', e);
    setCurrentMenu(e.key);
  }

  return (<Layout className="layout">
    <PageHeader title="Microblog" subTitle="李铭的第五课作业"></PageHeader>
    <Layout>
      <Sider className="sider">
        <Menu onClick={onMenuSwitched}
        defaultSelectedKeys={['post']}>
          <Menu.Item key="post">我的博文</Menu.Item>
          <Menu.Item key="followers">我关注的人</Menu.Item>
          <Menu.Item key="timeline">timeline</Menu.Item>
        </Menu></Sider>
      <Content>
        {currentMenu == 'post' && <MyPost />}
        {currentMenu == 'followers' && <MyFollow />}
        {currentMenu == 'timeline' && <TimeLine />}
      </Content>
    </Layout>
    {/* <Footer>Footer</Footer> */}
  </Layout>
  );
}

ReactDOM.render(<App />, document.body);


/*
document.querySelector("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const button = e.target.querySelector("button");

  const name = document.getElementById("name").value.toString();

  button.setAttribute("disabled", true);

  // Interact with foo actor, calling the greet method
  const greeting = await microblog.greet(name);

  button.removeAttribute("disabled");

  document.getElementById("greeting").innerText = greeting;

  return false;
});
*/
