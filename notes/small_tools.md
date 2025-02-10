# yaml and argparse
读取yaml文件 并且使用argparse去加载yaml_config 就可以实现类似于dataclass的功能 这样可以把所有需要的配置放到一个文件中
<br> 比如下面的代码 
```
# config.yaml
param1: value1
param2: 123
param3: [item1, item2, item3]
```
```
param1: value1
param2: 123
param3: ['item1', 'item2', 'item3']
```
```
try:
        with open(yaml_file_path, "r") as yaml_file:
            yaml_config = yaml.safe_load(yaml_file)
        # 创建 argparse.Namespace 对象
        args = argparse.Namespace(**yaml_config)
        # print argument 
        for arg, value in vars(args).items():
            print(f"{arg}: {value}")
    except FileNotFoundError:
        print(f"no yaml file found: {yaml_file_path}")
    except yaml.YAMLError as e:
        print(f"prase yaml file failed: {e}")
    pass
```
