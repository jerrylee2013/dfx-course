import { microblog } from "../../declarations/microblog";
import React, { useState, useEffect, useRef } from 'react';
import { Card, Form, Input, Button, message, Divider, Tabs, Typography, Spin, Space } from 'antd';
import {
    ReloadOutlined
} from '@ant-design/icons';
import BlogTable from "./blogtable";
const { TabPane } = Tabs;
const { Text } = Typography;

const MyPost = (props) => {
    const [currentTab, setCurrentTab] = useState('post');
    const [nicknameLoading, setNicknameLoading] = useState(false);
    const [nickname, setNickname] = useState('');
    const [nicknameUpdating, setNicknameUpdating] = useState(false);
    const [posting, setPosting] = useState(false);
    const actionRef = useRef();
    const onTabChanged = (key) => {
        setCurrentTab(key);
    }

    const getNickname = async () => {
        setNicknameLoading(true);
        try {
            let name = await microblog.get_name();
            setNickname(name);
        } catch (error) {
            message.error('获取昵称失败' + error);
        }
        setNicknameLoading(false);

    }

    const onNicknameFinish = async (values) => {
        console.log('Success:', values);
        setNicknameUpdating(true);
        try {
            await microblog.set_name(values.content);
            message.info('昵称修改成功!');
        } catch (error) {
            message.error('昵称修改失败!' + error);
        }
        setNicknameUpdating(false);
    };

    const onNicknameFinishFailed = (errorInfo) => {
        console.log('nickname Failed:', errorInfo);
    };

    const onPostFinish = async (values) => {
        console.log('Success:', values);
        setPosting(true);
        try {
            await microblog.post(values.content);
            message.info('博文发送成功!');
        } catch (error) {
            message.error('博文发送失败!' + error);
        }
        setPosting(false);
    };

    const onPostFinishFailed = (errorInfo) => {
        console.log('post Failed:', errorInfo);
    };

    useEffect(() => {
        getNickname();
        if (actionRef && actionRef.current) {
            actionRef.current.reloadAndRest();
        }
    }, []);
    useEffect(() => {
        if (!nicknameUpdating) {
            getNickname();
        }

    }, [nicknameUpdating]);
    useEffect(() => {
        if (!posting && actionRef && actionRef.current) {
            actionRef.current.reloadAndRest();
        }
    }, [posting]);

    return (
        <div>
            <Tabs defaultActiveKey="post" onChange={onTabChanged}>
                <TabPane tab="发博文" key="post">
                    <Card title="发新博文(注：本版不做身份校验，任何身份都可以替作者发文)">
                        <Form
                            name="newPost"
                            initialValues={{}}
                            onFinish={onPostFinish}
                            onFinishFailed={onPostFinishFailed}
                            autoComplete="off"
                        >
                            <Form.Item
                                label="博文内容"
                                name="content"
                                rules={[{ required: true, message: '请输入博文内容!' }]}
                            >
                                <Input.TextArea />
                            </Form.Item>
                            <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
                                <Button type="primary" htmlType="submit" loading={posting}>
                                    提交
                                </Button>
                            </Form.Item>
                        </Form>

                    </Card>
                </TabPane>
                <TabPane tab="修改昵称" key="myinfo">
                    <Space>
                        <Text>当前昵称为：
                            {!nicknameLoading && <Text type="success">{nickname}</Text>}
                            {nicknameLoading && <Spin />}
                        </Text>
                        <Button type="primary" shape="circle" loading={nicknameLoading}
                            icon={<ReloadOutlined />}
                            onClick={() => {
                                getNickname();
                            }}
                        />
                    </Space>
                    <Form
                        name="newName"
                        initialValues={{}}

                        onFinish={onNicknameFinish}
                        onFinishFailed={onNicknameFinishFailed}
                        autoComplete="off"
                    >
                        <Form.Item
                            label="新昵称"
                            name="content"
                            rules={[{ required: true, message: '请输入昵称!' }]}
                        >
                            <Input.TextArea />
                        </Form.Item>
                        <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
                            <Button type="primary" htmlType="submit" loading={nicknameUpdating}>
                                提交
                            </Button>
                        </Form.Item>
                    </Form>
                </TabPane>
            </Tabs>

            <Divider />
            <Card title="我的所有历史博文">
                <BlogTable 
                actionRef={actionRef}
                microblogMethod={microblog.posts}
                showTimeFilter={false}
                showAuthor={false}
                />
            
            </Card>

        </div>
    );
}

export default MyPost;